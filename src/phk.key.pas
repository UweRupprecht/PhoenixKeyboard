unit phk.key;

interface
uses
  winapi.Windows,
  winapi.Messages,
  system.Classes,
  system.Generics.Collections,
  phk.command;


Type
  TPhkSpecialKey = (skNone,skLShif,skRShift,skShift,skLControl,skRControl,skControl,skLAlt,skRAlt,skAlt);
  TPhkSpecialKeys = Set Of TPhkSpecialKey;

Const
  cPhkKeys : Array[TPhkSpecialKey] of WideString = (
  'None','LShift','RShift','Shift','LCtrl','RCtrl','Ctrl','LAlt','RAlt','Alt'
  );

Type
  //Key/Process type
  //None = Not defined; No command executed; Default value
  //Direct = command execute after 2 Keystrikes (Ctrl+f)
  //Second = Second keystroke needed before executed (Alt+f s)
  TPhkKeyType = (ktNone,ktSingle,ktDouble);
  TPhkKeyState = (ksNone,ksEnter,ksTrigger);

  TPhkKey = Class(TPersistent)
  private
     fKeyType    : TPhkKeyType;
     fSpecialKey : TPhkSpecialKey;
     fEnterKey   : Word;    //Keycode first needed for double mode
     fTriggerKey : Word;    //Keycode Needed for direct or double mode to trigger action
     fEnable     : boolean;
     fState      : TPhkKeyState;
     fCmd        : TPhkCommand;
  protected

  public
     constructor Create;
     Destructor Destroy;override;
     //Just check if it is a Hotkey, without state changes and not use enable
     function isHotkey(SpecialKeys:TPhkSpecialKeys;Keycode:Word):Boolean;
     //check and set the keystate;If Triggert also trigger the command(s)
     function HotKey(SpecialKeys:TPhkSpecialKeys;KeyCode:Word):TPhkKeyState;

  published
     Property KeyKind       : TPhkKeyType read fkeytype write fkeytype;
     Property ActivationKey : TPhkSpecialKey read fspecialkey write fspecialkey;
     Property EnterKey      : word read fEnterKey write fenterKey;
     Property TriggerKey    : word read fTriggerKey write ftriggerKey;
     Property Enable        : boolean read fenable write fenable;
     Property Command       : TPhkCommand read fcmd;
  End;

  TPHKKeys = class
  private
      fitems : TObjectlist<TPHKKey>;

      function GetItem(Index:integer):TPHKKey;
  protected
  public
      constructor Create;
      Destructor Destroy;override;

      function Add:integer;
      procedure Delete(index:integer);
      function count:integer;

      function HotKeyExists(SpecialKey:TPhkSpecialKeys;AKey:Word):boolean;
      Procedure HandleHotKey(SpecialKey:TPhkSpecialKeys;AKey:word);

      function GetEnumerator:TEnumerator<TPHKKey>;

      Property Items[index:integer] :TPHKKey read GetItem;
  published
  end;

implementation

{ TPhkKey }

constructor TPhkKey.Create;
begin
  inherited;
  fKeyType := ktNone;
  fspecialKey := skNone;
  fEnterkey := 0;
  fTriggerKey := 0;
  fenable := true;
  fstate := ksNone;
  fCmd   := TPhkCommand.create;
end;

destructor TPhkKey.Destroy;
begin
  fcmd.free;
  inherited;
end;

function TPhkKey.HotKey(SpecialKeys: TPhkSpecialKeys;
  KeyCode: Word): TPhkKeyState;
begin
  //Hotkey is disabled
  if (not fenable) or (fKeyType = ktNone) then exit;
  if (fKeyType = ktSingle) then
  begin
    if (fSpecialKey in SpecialKeys) and (KeyCode = fTriggerKey) then
    begin
      fstate := ksTrigger;
      result := fstate;
      if assigned(fcmd) then
        fcmd.execute;
    end;
  end
  else
  begin
    if (fstate = ksNone) and (fSpecialKey in SpecialKeys) and (KeyCode = fEnterKey) then
    begin
      fstate := ksEnter;
      result := fState;
    end
    else if (fState = ksEnter) and (KeyCode = fTriggerKey) then
    begin
      fstate := ksTrigger;
      result := fstate;
      if (assigned(fcmd)) then
        fcmd.Execute;
    end;
  end;
end;

function TPhkKey.isHotkey(SpecialKeys: TPhkSpecialKeys; Keycode: Word): Boolean;
begin
  result := false;
  if (fKeytype = ktNone) then exit;
  if (fKeyType = ktSingle) then
  begin
    if (fSpecialKey in SpecialKeys) and (KeyCode = fTriggerKey) then
      result := true;
  end
  else
  begin
    if (fState = ksNone) and (fSpecialKey in SpecialKeys) and (Keycode = fEnterKey) then
        result := true;
    if (fstate = ksEnter) and (KeyCode = fTriggerKey)  then
        result := true;
  end;
end;


{ TPHKKeys }

function TPHKKeys.Add: integer;
begin
  result := Fitems.Add(TPhkkey.create);
end;

function TPHKKeys.count: integer;
begin
  result := Fitems.count;
end;

constructor TPHKKeys.Create;
begin
  inherited;
  fitems := TObjectList<TPHKKey>.create(true);
end;

procedure TPHKKeys.Delete(index: integer);
begin
  fitems.Delete(index);
end;

destructor TPHKKeys.Destroy;
begin
  fitems.Free;
  inherited;
end;

function TPHKKeys.GetEnumerator: TEnumerator<TPHKKey>;
begin
  result := fitems.GetEnumerator;
end;

function TPHKKeys.GetItem(Index: integer): TPHKKey;
begin
  result := nil;
  if (index >= 0) and (index < fitems.count) then
    result := fitems[index];
end;

procedure TPHKKeys.HandleHotKey(SpecialKey: TPhkSpecialKeys; AKey: word);
begin
  for var k in fitems do
  begin
    if k.isHotkey(SpecialKey,AKey) then
      k.HotKey(SpecialKey,Akey);
  end;
end;

function TPHKKeys.HotKeyExists(SpecialKey: TPhkSpecialKeys; AKey: Word): boolean;
begin
  result := false;
  for var k in fitems do
  begin
    if k.isHotkey(SpecialKey,AKey) then
    begin
      result := true;
      exit;
    end;
  end;
end;

end.
