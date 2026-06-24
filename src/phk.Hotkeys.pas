unit phk.Hotkeys;
(*
   Definition of Hotkeys
*)

interface
uses
  winapi.Windows,
  system.Classes,
  system.Generics.Collections,
  phk.general,
  phk.keys,
  phk.command;

Type
  THotKeyKind = (hkSingle,hkComplex); //Kind of Hotkey (Single keystroke or Multiple)
  THotKeyState = (hkNone,hkDisabled,hkInMode,hkTrigger);
  THotKeyStates = Set of THotKeyState;

  //Definition of a single Hotkey
  THotKey = Class
  private
    fKey : TPHK_Keys; //We can have more than one keystroke !
    fKind : THotKeyKind;
    fstate : THotKeyStates;
    fCmd   : TPHKCommands; //maybe multiple commands
  protected
      function GetState(index:THotKeyState):boolean;
      Procedure SetState(index:THotKeyState;value:boolean);
  public
    constructor Create;
    Destructor Destroy;override;

    function HandleKeyStroke(Code:DWord;Modifier:phk_ModifierKeys):THotKeyState;
    function CheckKeyStroke(ACode:Dword;Modifier:phk_ModifierKeys):boolean;

  published
      Property Keys : TPhk_Keys read fkey;
      Property Kind : THotKeyKind read fKind;
      Property Commands : TPHKCommands read fcmd;
      Property ModeActive : boolean index hkInMode read GetState;
      Property Disable : boolean index hkDisabled read GetState Write SetState;
      Property Triggered: boolean index hkTrigger read GetState;
  End;

  //List of hotkey definitions
  THotKeys = Class
  private
      fHots : TObjectList<THotKey>;
  protected
    function GetHotKey(index:integer):THotKey;
  public
    constructor Create;
    Destructor Destroy;override;
    //Hotkey handling
    //Handles the hotkey; true if handled false if not
    function HandleHotKey(ACode:DWord;Modifier:phk_ModifierKeys):boolean;
    //Just check if a keystroke is matching a hotkey;without execute
    function MatchHotkey(ACode:DWord;Modifier:phk_ModifierKeys;out HotKey:THotkey): boolean;


    //List functions
    function Add:integer;
    function Delete(index:integer):boolean;
    function Count:integer;

    //Enumeration
    function GetEnumerator:TEnumerator<THotKey>;

    //Propertys
    Property HotKey[index:integer]:THotKey read GetHotKey;
  published
  End;


implementation

{ THotKey }

function THotKey.CheckKeyStroke(ACode: Dword;
  Modifier: phk_ModifierKeys): boolean;
var
  i : integer;
  tmp : THotKeyState;
begin
  result := false;
  if (hkDisabled in fstate) then
    exit;
  for I := 0 to fkey.count-1 do
  begin
      if fkey[i].MatchKey(acode,modifier) then
      begin
        result := true;
        exit;
      end;
  end;
end;

constructor THotKey.Create;
begin
  inherited;
  fkey := TPHK_Keys.create;
  fcmd := TPHKCommands.create;
  fkind := hkSingle;
  fstate := [];
end;

destructor THotKey.Destroy;
begin
  fkey.free;
  fcmd.free;
  inherited;
end;

function THotKey.GetState(index: THotKeyState): boolean;
begin
  result := index in fstate;
end;

function THotKey.HandleKeyStroke(Code: DWord;
  Modifier: phk_ModifierKeys): THotKeyState;
var
  i : integer;
  tmp : boolean;
begin
  result := hkNone;
  if (hkDisabled in fstate) then
  begin
    result := hkDisabled;
    exit;
  end;
  for I := 0 to fkey.count-1 do
  begin
    tmp := fkey[i].MatchKey(code,modifier);
    if tmp and (i < fkey.count-1) then
      result := hkInMode;
    if tmp and (i = fkey.count-1) then
      result := hkTrigger;
  end;
  if result = hkTrigger then
    fcmd.ExecuteAll;
end;

procedure THotKey.SetState(index: THotKeyState; value: boolean);
begin
  if value then
    include(fstate,index)
  else
    exclude(fstate,index);
end;

{ THotKeys }

function THotKeys.Add: integer;
begin
  result := fHots.Add(THotKey.create);
end;

function THotKeys.Count: integer;
begin
  result := fhots.count;
end;

constructor THotKeys.Create;
begin
  inherited;
  fhots := TObjectList<THotKey>.create(true);
end;

function THotKeys.Delete(index: integer): boolean;
begin
  result := false;
  if (index >= 0) and (index < fhots.count) then
  begin
    fhots.Delete(index);
    result := true;
  end;
end;

destructor THotKeys.Destroy;
begin
  fhots.clear;
  fhots.free;
  inherited;
end;

function THotKeys.GetEnumerator: TEnumerator<THotKey>;
begin
  result := fhots.GetEnumerator;
end;

function THotKeys.GetHotKey(index: integer): THotKey;
begin
  result := NIL;
  if (index >= 0) and (index < fhots.count) then
    result := fhots[index];
end;

function THotKeys.HandleHotKey(ACode: DWord;
  Modifier: phk_ModifierKeys): boolean;
begin
  result := false;
  for var k in fhots do
  begin
    if (k.HandleKeyStroke(ACode,Modifier) in [hkInMode,hkTrigger]) then
    begin
      result := true;
      break;
    end;
  end;
end;

function THotKeys.MatchHotkey(ACode: DWord; Modifier: phk_ModifierKeys;
  out HotKey: THotkey): boolean;
var
  i : integer;
begin
  result := false;
  HotKey := NIL;
  for i := 0 to fhots.count-1 do
  begin
    if fhots[i].CheckKeyStroke(ACode,Modifier) then
    begin
      result := true;
      HotKey := fhots[i];
      exit;
    end;
  end;
end;

end.
