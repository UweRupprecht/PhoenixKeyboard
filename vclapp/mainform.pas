unit mainform;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,CodeSiteLogging,Vcl.StdCtrls,phk.manager,phk.general,
  System.Actions, Vcl.ActnList;


type
  TForm54 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    mdb: TMemo;
    al: TActionList;
    acAction: TAction;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure acActionExecute(Sender: TObject);
  private
    { Private-Deklarationen }
    Procedure WmPHKHotkey(var msg:TMessage);message WM_PHKHOTKEY;
  public
    { Public-Deklarationen }
    procedure hotkeyCommand(Sender:TObject);
  end;

var
  Form54: TForm54;

implementation
{$R *.dfm}

{ TForm54 }

procedure TForm54.acActionExecute(Sender: TObject);
begin
  mdb.lines.append('Action triggert');
end;

procedure TForm54.Button1Click(Sender: TObject);
begin
  Hotkeymanager.Start(hmLocal);
  mdb.lines.append('Hook activated');
end;

procedure TForm54.Button2Click(Sender: TObject);
begin
  mdb.lines.append('Hook deactivated');
  Hotkeymanager.Stop;
end;

procedure TForm54.Button3Click(Sender: TObject);
var
  HotId:integer;
begin
  HotId := HotkeyManager.AddHotkey(Ord('F'),[mkControl]);
  HotKeyManager.AddHotkeyEvent(HotID,HotkeyCommand);

  HotId := HotkeyManager.AddHotkey(Ord('F'),[mkLAlt]);
  Hotkeymanager.AddHotkeyMessage(HotId,handle);

  HotId := HotKeyManager.AddHotkey(Ord('G'),[mkLControl]);
  HotkeyManager.AddHotkeyAction(HotId,acAction);
end;

procedure TForm54.hotkeyCommand(Sender: TObject);
begin
  mdb.lines.append('Event triggert');
end;

procedure TForm54.WmPHKHotkey(var msg: TMessage);
begin
  mdb.Lines.append('Message WM_PHKHOTKEY');
end;

end.
