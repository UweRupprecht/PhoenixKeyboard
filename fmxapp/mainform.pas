unit mainform;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  winapi.Windows,winapi.Messages,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo,phk.manager,phk.general, System.Actions, FMX.ActnList;

type
  TForm55 = class(TForm)
    btnstart: TButton;
    btnEnd: TButton;
    btncreate: TButton;
    mdb: TMemo;
    ac: TActionList;
    acAction: TAction;
    procedure acActionExecute(Sender: TObject);
    procedure btnstartClick(Sender: TObject);
    procedure btnEndClick(Sender: TObject);
    procedure btncreateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private-Deklarationen }
    fhlp : TFMXHelperWindow;
    Procedure DoKeyMessage(var msg:TMessage);
  public
    { Public-Deklarationen }
    procedure hotkeyCommand(Sender:TObject;customdata:TCustomdata);
  end;

var
  Form55: TForm55;

implementation
uses
  fmx.Platform.Win;
{$R *.fmx}

procedure TForm55.acActionExecute(Sender: TObject);
begin
  mdb.lines.append('Action Hotkey triggered');
end;

procedure TForm55.btncreateClick(Sender: TObject);
var
  ci,ki,idx : integer;

begin
 idx := HotkeyManager.Hotkeys.Add;
  ki := Hotkeymanager.Hotkeys.HotKey[idx].Keys.Add(Ord('F'),[mkControl]);
  ki := HotKeymanager.Hotkeys.HotKey[idx].Keys.Add(Ord('F'),[mkControl]);
  ki := Hotkeymanager.hotkeys.HotKey[idx].keys.add(Ord('A'),[mkNone]);
  ci := HotKeyManager.Hotkeys.HotKey[idx].Commands.Add;
  hotkeymanager.Hotkeys.HotKey[idx].Commands.cmd[ci].CommandEvent := true;
  hotkeymanager.Hotkeys.HotKey[idx].Commands.cmd[ci].OnCommand := HotkeyCommand;

  idx := HotkeyManager.Hotkeys.Add;
  ki := Hotkeymanager.Hotkeys.HotKey[idx].Keys.Add(Ord('F'),[mkAlt]);
  ci := HotKeyManager.Hotkeys.HotKey[idx].Commands.Add;
  hotkeymanager.Hotkeys.HotKey[idx].Commands.cmd[ci].CommandMessage := True;
  Hotkeymanager.Hotkeys.HotKey[idx].Commands.cmd[ci].TargetHandle := fhlp.Handle;

  idx := HotkeyManager.Hotkeys.Add;
  ki := Hotkeymanager.Hotkeys.HotKey[idx].Keys.Add(Ord('G'),[mkControl]);
  ci := HotKeyManager.Hotkeys.HotKey[idx].Commands.Add;
  hotkeymanager.Hotkeys.HotKey[idx].Commands.cmd[ci].CommandAction := true;
  Hotkeymanager.Hotkeys.HotKey[idx].Commands.cmd[ci].Action := acAction;

end;

procedure TForm55.btnEndClick(Sender: TObject);
begin
  hotkeymanager.StartHooking;
  mdb.lines.append('Hook disabled');
end;

procedure TForm55.btnstartClick(Sender: TObject);
begin
  hotkeymanager.StartHooking;
  mdb.lines.append('Hook active');
end;

procedure TForm55.DoKeyMessage(var msg: TMessage);
begin
  mdb.Lines.append('Key Messageing on FMX');
end;

procedure TForm55.FormCreate(Sender: TObject);
begin
  fhlp := TFMXHelperWindow.create;
  fhlp.onMessage := DoKeyMessage;
end;

procedure TForm55.FormDestroy(Sender: TObject);
begin
  fhlp.free;
end;

procedure TForm55.hotkeyCommand(Sender: TObject;Customdata:Tcustomdata);
begin
  Mdb.lines.append('Hotkey Command');
end;

end.
