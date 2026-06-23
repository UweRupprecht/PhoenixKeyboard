unit mainform;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,CodeSiteLogging,Vcl.StdCtrls;


type
  TTest = (tNum1,tNum2,tNum3,tNum4,tNum5,tNum6,tNum7,tNum8,tNum9,tNum10);
  TTests = set of TTest;

  TForm54 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form54: TForm54;

implementation
uses
  system.TypInfo;
{$R *.dfm}

{ TForm54 }

procedure TForm54.Button1Click(Sender: TObject);
var
  a,b : TTests;

begin
  a := [tNum3,tNum4,tNum5,tNum6,tNum7];
//  b := [tNum3,tNum6];
  b := [tNum3,tNum4,tNum5,tNum6,tNum7];
  if (b = a) then
    ShowMessage('Equal');
  if (b <= a) then
    ShowMessage('LessEqual');
  if (b >= a) then
    ShowMessage('GreaterEqual');
end;

end.
