program Keyboarddev;

uses
  FastMM5,
  Vcl.Forms,
  mainform in 'mainform.pas' {Form54},
  phk.general in '..\src\phk.general.pas',
  phk.keys in '..\src\phk.keys.pas',
  phk.command in '..\src\phk.command.pas',
  phk.Hotkeys in '..\src\phk.Hotkeys.pas';

{$R *.res}

Procedure Configfastmmdebug;
Begin
  {puts fastmm in debug mode.  in order to obtain stack traces for leaks and errors you need to do the following:
  1) Enable a detailed map file in Project Options under Linking -> Map File
  2) Put the FastMM_FullDebugMode.dll (FastMM_FullDebugMode64.dll for 64-bit) in the same folder as the executable.
  3) Either put the .map file in the same folder as the executable OR embed JCL debug info into the executable.}
  Fastmm_enterdebugmode;

  {We do not want any dialog boxes for errors or leaks.}
  Fastmm_messageboxevents := [Mmetunexpectedmemoryleakdetail,
    Mmetunexpectedmemoryleaksummary];

  {We want all errors, memory leak details as well as leak summaries logged to a text file.}
  Fastmm_logtofileevents := Fastmm_logtofileevents +
    [Mmetunexpectedmemoryleakdetail, Mmetunexpectedmemoryleaksummary];
End;

begin
  {$ifdef DEBUG}
     ConfigFastMMDebug;
  {$endif}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm54, Form54);
  Application.Run;
end.
