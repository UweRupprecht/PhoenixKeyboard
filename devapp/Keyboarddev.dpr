program Keyboarddev;

uses
  Vcl.Forms,
  mainform in 'mainform.pas' {Form54},
  phoenixkeyboard in '..\src\phoenixkeyboard.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm54, Form54);
  Application.Run;
end.
