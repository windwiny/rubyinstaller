// DevKit Inno Setup GUI Customizations
//
// Copyright (c) 2010 Jon Maken
// Revision: 08/30/2010 8:49:54 PM
// License: MIT

var
  DkChkBox: TNewCheckBox;
  RubiesPageID: Integer;


{ GUI Event Handlers }
procedure DkChkBox_OnClick(Sender: TObject);
begin
  if DkChkBox.Checked then
  begin
    WizardForm.NextButton.Caption := '&Next >';
  end
  else
    WizardForm.NextButton.Caption := '&Install';
end;


{ Modify the GUI }
procedure InitializeWizard;
var
  Page: TWizardPage;
begin
  Page := PageFromID(wpSelectDir);

  DkChkBox := TNewCheckBox.Create(Page);
  DkChkBox.Parent := Page.Surface;
  DkChkBox.State := cbUnchecked;
  DkChkBox.Caption := 'Add DevKit functionality to installed Rubies.';
  DkChkBox.Alignment := taRightJustify;
  DkChkBox.Top := ScaleY(95);
  DkChkBox.Left := ScaleX(18);
  DkChkBox.Width := Page.SurfaceWidth;
  DkChkBox.Height := ScaleY(17);
  DkChkBox.OnClick := @DkChkBox_OnClick;

end;

procedure CreateRubiesPage;
var
  Page: TWizardPage;
begin
  { TODO - create scrollable panel and widgets for browsing fs }
  Page := CreateCustomPage(wpSelectDir, 'DevKit Enhancement',
                           'Select installed Rubies to enhance with DevKit functionality');
  RubiesPageID := Page.ID;
end;


{ Install or show custom page for selecting Rubies to enhance }
function NextButtonClick(CurPageID: Integer): Boolean;
begin
  if CurPageID = wpSelectDir then
  begin
    if DkChkBox.Checked then
    begin
      CreateRubiesPage;

      Result := True;
    end
    else
      // install without injecting DevKit functionality
      Result := True;
  end
  else
    // allow all other pages to proceed without NextButtonClick verification
    Result := True;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  case CurPageID of
    wpSelectDir, RubiesPageID: WizardForm.NextButton.Caption := '&Install';
  end;
end;
