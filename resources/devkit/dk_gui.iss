// DevKit Inno Setup GUI Customizations
//
// Copyright (c) 2010 Jon Maken
// Revision: 08/01/2010 8:24:25 PM
// License: MIT

var
  DkChkBox, DkExtraChkBox: TNewCheckBox;
  DkExtras: TNewEdit;
  TmpFont: TFont;


{ GUI Event Handlers }
procedure DkExtras_OnClick(Sender: TObject);
begin
  TmpFont.Free;

  TmpFont := TFont.Create;
  TmpFont.Color := $00000099;
  DkExtras.Font := TmpFont;
  DkExtras.Text := '';
end;

procedure DkExtraChkBox_OnClick(Sender: TObject);
begin
  if DkExtras.Visible then
  begin
    DkExtras.Hide;
    DkExtras.Clear;
  end
  else
    DkExtras.Show;
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
  DkChkBox.Caption := 'Add DevKit capabilities to RubyInstaller installations.';
  DkChkBox.Alignment := taRightJustify;
  DkChkBox.Top := ScaleY(95);
  DkChkBox.Left := ScaleX(18);
  DkChkBox.Width := Page.SurfaceWidth;
  DkChkBox.Height := ScaleY(17);

  DkExtraChkBox := TNewCheckBox.Create(Page);
  DkExtraChkBox.Parent := Page.Surface;
  DkExtraChkBox.State := cbUnchecked;
  DkExtraChkBox.Caption := 'Add DevKit capabilities to other Ruby installations.';
  DkExtraChkBox.Alignment := taRightJustify;
  DkExtraChkBox.Top := ScaleY(112);
  DkExtraChkBox.Left := ScaleX(18);
  DkExtraChkBox.Width := Page.SurfaceWidth;
  DkExtraChkBox.Height := ScaleY(17);
  DkExtraChkBox.OnClick := @DkExtraChkBox_OnClick;

  DkExtras := TNewEdit.Create(Page);
  DkExtras.Parent := Page.Surface;
  DkExtras.Text := 'Enter semicolon delimited Ruby root directories...';

  TmpFont := TFont.Create;
  TmpFont.Color := $00666666;
  TmpFont.Style := [fsItalic];

  DkExtras.Font := TmpFont;
  DkExtras.Top := ScaleY(129);
  DkExtras.Left := ScaleX(34);
  DkExtras.Width := Page.SurfaceWidth - ScaleX(120);
  DkExtras.Height := ScaleY(17);
  DkExtras.OnClick := @DkExtras_OnClick;
  DkExtras.Hide;

end;

procedure CurPageChanged(CurPageID: Integer);
begin
  case CurPageID of
    wpSelectDir: WizardForm.NextButton.Caption := '&Install';
  end;
end;
