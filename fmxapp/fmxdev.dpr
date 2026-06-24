program fmxdev;

uses
  System.StartUpCopy,
  FMX.Forms,
  mainform in 'mainform.pas' {Form55},
  phk.command in '..\src\phk.command.pas',
  phk.general in '..\src\phk.general.pas',
  phk.Hotkeys in '..\src\phk.Hotkeys.pas',
  phk.keys in '..\src\phk.keys.pas',
  phk.manager in '..\src\phk.manager.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm55, Form55);
  Application.Run;
end.
