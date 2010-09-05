// DevKit Inno Setup GUI Customizations
//
// Copyright (c) 2010 Jon Maken
// Revision: 09/04/2010 9:20:41 AM
// License: MIT

{ globals }
var
  DkChkBox: TNewCheckBox;
  RubiesPageID: Integer;
  AddBtn: TNewButton;


{ forward declarations }
procedure CreateRubiesPage; forward;
procedure DkChkBox_OnClick(Sender: TObject); forward;


{ modify the GUI }
procedure InitializeWizard;
var
  Page: TWizardPage;
begin
  Page := PageFromID(wpSelectDir);

  DkChkBox := TNewCheckBox.Create(Page);
  DkChkBox.Parent := Page.Surface;
  DkChkBox.State := cbUnchecked;
  DkChkBox.Caption := 'Add DevKit enhancements to installed Rubies.';
  DkChkBox.Alignment := taRightJustify;
  DkChkBox.Top := ScaleY(90);
  DkChkBox.Left := ScaleX(18);
  DkChkBox.Width := Page.SurfaceWidth;
  DkChkBox.Height := ScaleY(17);
  DkChkBox.OnClick := @DkChkBox_OnClick;

  CreateRubiesPage;
end;


{ installer event handlers }
function ShouldSkipPage(PageID: Integer): Boolean;
begin
  if PageID = RubiesPageID then begin
    if not DkChkBox.Checked then Result := True;
  end else begin
    Result := False;
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  // TODO - pre-install validation for Rubies page
  //        ensure all dirs have a 'bin' subdir
  //        containing a ruby.exe|jruby.exe|rbx.exe
  Result := True;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  case CurPageID of
    wpSelectDir:
      begin
        if not DkChkBox.Checked then WizardForm.NextButton.Caption := '&Install';
        AddBtn.Hide;
      end;
    RubiesPageID:
      begin
        WizardForm.NextButton.Caption := '&Install';
        AddBtn.Show;
      end;
    else
      begin
        AddBtn.Hide;
      end;
  end;
end;


{ GUI event handlers }
procedure DkChkBox_OnClick(Sender: TObject);
begin
  if (Sender as TNewCheckBox).Checked then begin
    WizardForm.NextButton.Caption := '&Next >';
  end else begin
    WizardForm.NextButton.Caption := '&Install';
  end;

end;

procedure AddBtn_OnClick(Sender: TObject);
var
  Page: TInputOptionWizardPage;
  Directory: String;
begin
  Page := PageFromID(RubiesPageID) as TInputOptionWizardPage;

  Directory := '';
  if BrowseForFolder('Select a Ruby root directory', Directory, False) then begin
    Page.AddEx(Directory, 1, False);
  end;
end;

{ custom pages and dialogs }
procedure CreateRubiesPage;
var
  Page: TInputOptionWizardPage;
begin
  Page := CreateInputOptionPage(wpSelectDir, 'DevKit Enhancement Configuration',
            'Select the Rubies to be DevKit enhanced',
            '', False, True);
  RubiesPageID := Page.ID;

  AddBtn := TNewButton.Create(Page);
  AddBtn.Caption := 'Add Ruby location';
  AddBtn.Width := ScaleX(100);
  AddBtn.Left := WizardForm.PageNameLabel.Left;
  AddBtn.Top := WizardForm.MainPanel.Top + WizardForm.MainPanel.Height + ScaleY(10);
  AddBtn.Parent := WizardForm;
  AddBtn.OnClick := @AddBtn_OnClick;

  // TODO - list automagically discovered Rubies
  Page.AddEx('Auto-Discovered Rubies:', 0, False);
  Page.AddEx('RubyInstaller 1.8.7', 1, False);
  Page.AddEx('RubyInstaller 1.9.1', 1, False);
  Page.AddEx('RubyInstaller 1.9.2', 1, False);

  // TODO - list dynamically discovered Rubies
  Page.AddEx('Additional Rubies:', 0, False);
end;
