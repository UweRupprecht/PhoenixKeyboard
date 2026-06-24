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
  Hotkeymanager.me.StartHooking;
  mdb.lines.append('Hook activated');
end;

procedure TForm54.Button2Click(Sender: TObject);
begin
  mdb.lines.append('Hook deactivated');
  Hotkeymanager.me.Stophooking;
end;

procedure TForm54.Button3Click(Sender: TObject);
var
  ci,ki,idx : integer;

begin
  idx := HotkeyManager.me.Hotkeys.Add;
  ki := Hotkeymanager.me.Hotkeys.HotKey[idx].Keys.Add(Ord('F'),[mkControl]);
  ki := HotKeymanager.me.Hotkeys.HotKey[idx].Keys.Add(Ord('F'),[mkControl]);
  ki := Hotkeymanager.me.Hotkeys.HotKey[idx].keys.add(Ord('A'),[mkNone]);
  ci := HotKeyManager.Me.Hotkeys.HotKey[idx].Commands.Add;
  hotkeymanager.me.Hotkeys.HotKey[idx].Commands.Items[ci].CommandEvent := true;
  hotkeymanager.me.Hotkeys.HotKey[idx].Commands.Items[ci].OnCommand := HotkeyCommand;

  idx := HotkeyManager.me.Hotkeys.Add;
  ki := Hotkeymanager.me.Hotkeys.HotKey[idx].Keys.Add(Ord('F'),[mkAlt]);
  ci := HotKeyManager.Me.Hotkeys.HotKey[idx].Commands.Add;
  hotkeymanager.me.Hotkeys.HotKey[idx].Commands.Items[ci].CommandMessage := True;
  Hotkeymanager.me.Hotkeys.HotKey[idx].Commands.items[ci].TargetHandle := handle;

  idx := HotkeyManager.me.Hotkeys.Add;
  ki := Hotkeymanager.me.Hotkeys.HotKey[idx].Keys.Add(Ord('G'),[mkControl]);
  ci := HotKeyManager.Me.Hotkeys.HotKey[idx].Commands.Add;
  hotkeymanager.me.Hotkeys.HotKey[idx].Commands.Items[ci].CommandAction := true;
  Hotkeymanager.me.Hotkeys.HotKey[idx].Commands.items[ci].Action := acAction;

end;

procedure TForm54.hotkeyCommand(Sender: TObject);
begin
  mdb.lines.append('Command');
end;

procedure TForm54.WmPHKHotkey(var msg: TMessage);
begin
  mdb.Lines.append('Message WM_PHKHOTKEY');
end;

end.
