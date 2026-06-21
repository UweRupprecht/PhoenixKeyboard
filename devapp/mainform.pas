unit mainform;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,CodeSiteLogging,   phk.command,phk.key,
  Vcl.StdCtrls;


type
  PMyData = ^TMyData;
  TMyData = Record
              text: String;
  End;

  TForm54 = class(TForm)
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
    fidx : integer;
    data : PMyData;

    Procedure WmKeyCommand(var msg:TMessage);message WM_PHKKEYCOMMAND;
  public
    { Public-Deklarationen }
    Key : TPhkKey;
  end;

var
  Form54: TForm54;

implementation

{$R *.dfm}

{ TForm54 }

procedure TForm54.Button1Click(Sender: TObject);
begin
  key.HotKey([skControl],ord('F'));
end;

procedure TForm54.FormCreate(Sender: TObject);
begin
  key := TPhkKey.create;
  key.KeyKind := ktSingle;
  key.ActivationKey := skControl;
  key.TriggerKey := Ord('F');
  key.Enable := true;
  key.Command.CommandMessage := true;
  key.Command.TargetHandle := handle;
  New(Data);
  data^.text := 'schaumermal';
  key.command.SetCustomData(data,sizeof(data^));
end;

procedure TForm54.FormDestroy(Sender: TObject);
begin
  Dispose(Data);
  key.free;
end;

procedure TForm54.WmKeyCommand(var msg: TMessage);
var
  data : PMyData;
  s : string;
begin
  s := 'Nix';
  if (msg.LParam > 0) then
  begin
    data := PMyData(msg.LParam);
    s := data^.text;
    dispose(data);
  end;
  CodeSite.Send('KEYCOMMAND: '+s)
end;

end.
