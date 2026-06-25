unit phk.keys;
(*
    Defines types and classes for defining and handling keystrokes
*)
interface
uses
  winapi.windows,
  System.UITypes,
  system.Generics.Collections,
  phk.general;

type
  //Defines a key with its data
  TPHK_Key = Class
  private
    fdata: TKeyData;
    function GetEnable: boolean;
    function GetKeyCode: DWord;
    function GetModifier: phk_ModifierKeys;
    procedure SetEnable(const Value: boolean);
    procedure SetKeyCode(const Value: DWord);
    procedure SetModifier(const Value: phk_ModifierKeys);
  protected
  public
    constructor Create;
    Destructor Destroy;override;
    //Set the data with one call;
    Procedure SetData(ACode:DWord;Modifiers:PHK_MODIFIERKEYS;state:TKeyState=ksNone);
    //Does the defines key matches a given Key (incl. Modifierkeys)
    function MatchKey(Code:Dword;Modifier:PHK_MODIFIERKEYS):boolean;
    //Current state of a key
    function KeyState:TKeyState;
    //Simply set the state, when the key was handled to pressed
    Procedure Triggert;

  published
     //Virtual Key code of the key
     Property Keycode     : DWord read GetKeyCode write SetKeyCode;
     //Modifier Key(s) that needs to be pressed
     Property Modifiers   : phk_ModifierKeys read GetModifier write SetModifier;
     Property Enabled     : boolean read GetEnable write SetEnable;
  end;

  //List of keystrokes
  TPHK_Keys = Class
  private
    fkeys : TObjectList<TPHK_KEY>;

  protected
    function GetKey(Index:integer):TPHK_KEY;
  public
    constructor Create;
    Destructor Destroy;override;

    //List handling stuff
    function Add:integer;overload;
    function Add(ACode:DWord;Modifiers:phk_ModifierKeys):integer;overload;
    function Remove(Index:integer):boolean;
    function Count:integer;

    //Enumerator Stuff
    function GetEnumerator:TEnumerator<TPHK_KEY>;

    Property Key[index:integer]:TPHK_key read GetKey;default;
  published
  End;

implementation

{ TPHK_Key }

constructor TPHK_Key.Create;
begin
  inherited create;
  fillchar(fdata,sizeof(fdata),0);
end;

destructor TPHK_Key.Destroy;
begin
  inherited;
end;

function TPHK_Key.GetEnable: boolean;
begin
  result := fdata.State <> ksDisabled;
end;

function TPHK_Key.GetKeyCode: DWord;
begin
  result := fdata.Code;
end;

function TPHK_Key.GetModifier: phk_ModifierKeys;
begin
  result := fdata.Modifier;
end;

function TPHK_Key.KeyState: TKeyState;
begin
  result := fdata.State;
end;

function TPHK_Key.MatchKey(Code: Dword; Modifier: PHK_MODIFIERKEYS): boolean;
begin
  result := (fdata.State <> ksDisabled) and (fdata.Code = code) and (ModifierCompare(Modifier,fdata.Modifier));
end;

procedure TPHK_Key.SetData(ACode: DWord; Modifiers: PHK_MODIFIERKEYS;
  state: TKeyState);
begin
  fdata.Code := ACode;
  fdata.Modifier := Modifiers;
  fdata.State := state;
end;

procedure TPHK_Key.SetEnable(const Value: boolean);
begin
  if (value) and (fdata.State = ksDisabled) then
    fdata.state := ksNone
  else if not value then
    fdata.state := ksDisabled;
end;

procedure TPHK_Key.SetKeyCode(const Value: DWord);
begin
  fdata.Code := value;
end;

procedure TPHK_Key.SetModifier(const Value: phk_ModifierKeys);
begin
  fdata.Modifier := value;
end;

procedure TPHK_Key.Triggert;
begin
  if (fdata.State <> ksDisabled) and (fdata.state <> ksPressed) then
    fdata.State := ksPressed;
end;

{ TPHK_Keys }

function TPHK_Keys.Add: integer;
begin
  result := fkeys.Add(TPHK_KEY.create);
end;

function TPHK_Keys.Add(ACode: DWord; Modifiers: phk_ModifierKeys): integer;
begin
  result := add;
  fkeys[result].Keycode := ACode;
  fkeys[result].Modifiers := Modifiers;
end;

function TPHK_Keys.Count: integer;
begin
  result := fkeys.count;
end;

constructor TPHK_Keys.Create;
begin
  inherited;
  fkeys := TObjectList<TPHK_KEY>.create(true);
end;

destructor TPHK_Keys.Destroy;
begin
  fkeys.free;
  inherited;
end;

function TPHK_Keys.GetEnumerator: TEnumerator<TPHK_KEY>;
begin
  result := fkeys.GetEnumerator;
end;

function TPHK_Keys.GetKey(Index: integer): TPHK_KEY;
begin
  if (index >= 0) and (index < fkeys.count) then
    result := fkeys[index];
end;

function TPHK_Keys.Remove(Index: integer): boolean;
begin
  result := false;
  if (index >= 0) and (index < fkeys.count) then
  begin
    fkeys.Delete(index);
    result := false;
  end;
end;

end.

