unit mainform;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,CodeSiteLogging,Vcl.StdCtrls,phk.manager;


type
  TForm54 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form54: TForm54;

implementation
{$R *.dfm}

{ TForm54 }

procedure TForm54.Button1Click(Sender: TObject);
begin
  Hotkeymanager.me.StartHooking;
end;

procedure TForm54.Button2Click(Sender: TObject);
begin
  Hotkeymanager.me.Stophooking;
end;

end.
