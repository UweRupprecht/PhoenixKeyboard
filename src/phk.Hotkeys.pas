unit phk.Hotkeys;
(*
    Types and classes for a complete Hotkey and
    a list of hotkeys
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
  //State of a Hotkey
  //hkNone = Nothing happend;Default
  //hkDisabled = the hotkey is disabled
  //hkInMode = One or a part of the keystrokes where triggert
  //hkTrigger = all defined keystrokes where done and the command(s) can be executed
  THotKeyState = (hkNone,hkDisabled,hkInMode,hkTrigger);

  //Definition of a single Hotkey
  THotKey = Class
  private
    fKey : TPHK_Keys; //We can have more than one keystroke !
    fstate : THotKeyState;
    fCmd   : TCommands; //maybe multiple commands
  protected
      function GetState(index:THotKeyState):boolean;
      Procedure SetState(index:THotKeyState;value:boolean);
  public
    constructor Create;
    Destructor Destroy;override;

    //Simple checks, if the given code and modifer matches one of the keystrokes
    //Does not modifing the state
    function MatchKey(ACode:DWord;Modifier:phk_modifierkeys):boolean;
    //Handles the given keystroke, set the state and if hkTrigger is reached
    //executes the defined command(s)
    function HandleKeyStroke(ACode:DWord;Modifier:phk_modifierkeys):THotKeyState;

    //Simplify handling
    function AddKey(ACode:DWord;Modifier:phk_ModifierKeys):integer;
    function DelKey(ACode:DWord;Modifier:phk_ModifierKeys):boolean;overload;
    function DelKey(Keyindex:integer):boolean;overload;


  published
      Property Keys : TPhk_Keys read fkey;
      Property Commands : TCommands read fcmd;
      Property ModeActive : boolean index hkInMode read GetState;
      Property Disable : boolean index hkDisabled read GetState Write SetState;
      Property Triggered: boolean index hkTrigger read GetState;
  End;

  //List of hotkey definitions
  THotKeys = Class
  private
      fkeys : TObjectList<THotKey>;
  protected
    function GetHotKey(index:integer):THotKey;
  public
    constructor Create;
    Destructor Destroy;override;

    //Only checks if the given keystroke matches a hotkey
    function MatchesHotkey(ACode:DWord;Modifiers:phk_modifierkeys):boolean;

    //Handles a given keystroke; states where modified and commands will be executed
    function HandleHotkey(ACode:DWord;Modifiers:phk_Modifierkeys):boolean;

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

function THotKey.MatchKey(ACode: Dword;Modifier: phk_ModifierKeys): boolean;
var
  i : integer;
  tmp : THotKeyState;
begin
  result := false;
  //if the hotkey is disabled, there is no match
  if (hkDisabled = fstate) then
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

function THotKey.AddKey(ACode: DWord; Modifier: phk_ModifierKeys): integer;
begin
  result := fkey.Add(ACode,Modifier);
end;

constructor THotKey.Create;
begin
  inherited;
  fkey := TPHK_Keys.create;
  fcmd := TCommands.create;
  fstate := hkNone;
end;

function THotKey.DelKey(ACode: DWord; Modifier: phk_ModifierKeys): boolean;
var
  i,idx : integer;
begin
  result := false;
  idx := -1;
  for I := 0 to fkey.count-1 do
  begin
    if fkey[i].MatchKey(ACode,Modifier) then
    begin
      idx := i;
      break;
    end;
  end;
  if (idx > -1) then
    result := fkey.Remove(idx);
end;

function THotKey.DelKey(Keyindex: integer): boolean;
begin
  result := fkey.Remove(Keyindex);
end;

destructor THotKey.Destroy;
begin
  fkey.free;
  fcmd.free;
  inherited;
end;

function THotKey.GetState(index: THotKeyState): boolean;
begin
  result := index = fstate;
end;

function THotKey.HandleKeyStroke(ACode:DWord;Modifier:phk_modifierkeys):THotKeyState;
var
  i : integer;
  tmp : boolean;
begin
  result := hkNone;
  //no need to handle the keystroke
  if (hkDisabled = fstate) then
  begin
    result := hkDisabled;
    exit;
  end;
  for I := 0 to fkey.count-1 do
  begin
    tmp := fkey[i].MatchKey(ACode,modifier);
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
    fstate := index;
end;

{ THotKeys }

function THotKeys.Add: integer;
begin
  result := fkeys.Add(THotKey.create);
end;

function THotKeys.Count: integer;
begin
  result := fkeys.count;
end;

constructor THotKeys.Create;
begin
  inherited;
  fkeys := TObjectList<THotKey>.create(true);
end;

function THotKeys.Delete(index: integer): boolean;
begin
  result := false;
  if (index >= 0) and (index < fkeys.count) then
  begin
    fkeys.Delete(index);
    result := true;
  end;
end;

destructor THotKeys.Destroy;
begin
  fkeys.free;
  inherited;
end;

function THotKeys.GetEnumerator: TEnumerator<THotKey>;
begin
  result := fkeys.GetEnumerator;
end;

function THotKeys.GetHotKey(index: integer): THotKey;
begin
  result := NIL;
  if (index >= 0) and (index < fkeys.count) then
    result := fkeys[index];
end;

function THotKeys.HandleHotKey(ACode: DWord;Modifiers: phk_ModifierKeys): boolean;
begin
  result := false;
  for var k in fkeys do
  begin
    if (k.HandleKeyStroke(ACode,Modifiers) in [hkInMode,hkTrigger]) then
    begin
      result := true;
      break;
    end;
  end;
end;

function THotKeys.Matcheshotkey(ACode: DWord; Modifiers: phk_ModifierKeys): boolean;
var
  i : integer;
begin
  result := false;
  for i := 0 to fkeys.count-1 do
  begin
    if fkeys[i].MatchKey(ACode,Modifiers) then
    begin
      result := true;
      exit;
    end;
  end;
end;

end.
