unit phoenixkeyboard;

interface
uses
  winapi.Windows,
  winapi.Messages,
  System.classes,
  System.Generics.Collections;

Type
  //Special keys we want to handle like TShiftStateItem without Mouse-Buttons
  TSpecialKeyItem = (skiNone,skiLShift,skiRShift,skiShift,skiLControl,skiRControl,skiControl,
                     skiLAlt,skiRAlt,skiAlt,skiEsc);
  TSpecialKeys = Set of TSpecialKeyItem;

  //Wether a single stroke should trigger the action (example: ALT+M is a single)
  //or a combo should trigger the action (Example: Alt+M T is a combo)
  TKeyMode = (kmSingle,kmCombo);
  TKeyCheck = (kcNone,kcEnter,kcTrigger);
  TKeyHandler = Class;

  TKeyAction = procedure (Key:TKeyHandler) of object;

  //Item for a key stroke
  TKeyHandler = Class
  Private
     fMode : TKeyMode;          //Mode for the action to trigger
     fKeyAction : TKeyCheck; //used for kmCombo mode for the state
     fEnterKey : Word;          //Enter key (kmCombo only)
     fTriggerKey : word;        //Trigger key (together with fspecial on single;else a single key)
     fSpecial : TSpecialKeyItem;
     fAction  : TBasicAction;
     fOnKey   : TKeyAction;
  public
     Constructor Create;
     Destructor Destroy;override;
     Procedure Execute;
     function CheckKeyStroke(Special:TSpecialKeyItem;key:word):TKeyCheck;
  Published
     Property Mode : TKeyMode read fmode write fmode;
     Property Enterkey : Word read fEnterKey write fenterkey;
     Property Triggerkey : Word read fTriggerKey write ftriggerKey;
     Property SpecialKey : TSpecialKeyItem read fspecial write fspecial;
  End;

  //Hold a list of keys together with there actions
  THotKeys = Class
  private
     fkeys : TObjectList<TKeyHandler>;
  protected
     function GetItem(index:integer):TKeyHandler;
  public
     Constructor Create;
     Destructor Destroy;override;

     //List handling
     function Add:integer;
     Procedure Remove(index:integer);
     function Count:integer;
     function Exists(Special:TSpecialKeys;Enter,Trigger:Word):boolean;

     //Enumerator handling
     function GetEnumerator:TEnumerator<TKeyHandler>;

     //More or less direct access to the items
     Property Keys[index:integer]:TKeyHandler read GetItem;default;
  published
  End;

implementation

{ TKeyHandler }

function TKeyHandler.CheckKeyStroke(Special: TSpecialKeyItem;
  key: word): TKeyCheck;
begin
  result := kcNone;
  //First check the mode
  if fMode = kmSingle then
  begin
    //On single mode we check the special key and the trigger key
    if (special = fSpecial) and (key = ftriggerkey) then
      Result := kcTrigger;
  end
  else
  begin
    //ok we are in combo-mode; First we check if a specialKey is given
    //and the Action is not already entered
    if (special <> skiNone) and (fkeyaction = kcNone) then
    begin
      //Check if special key is the same as defined and also the enterkey is correct
      //Then we switch to Action-Enter-Mode
      if (special = fspecial) and (fenterkey = key) then
      begin
        fKeyAction := kcEnter;
        result := kcEnter;
      end;
    end
    else
    begin
      //Ok, check we already entered and the key is the triggerkey
      //Then we clean the internal action mode and say the list, we have to
      //Execute the action/event
      if (fKeyAction = kcEnter) and (ftriggerkey = key) then
      begin
        fkeyaction := kcNone;
        result := kcTrigger;
      end;
    end;
  end;
end;

constructor TKeyHandler.Create;
begin
  inherited;
  fmode := kmSingle;
  fEnterKey := 0;
  fTriggerkey := 0;
  fspecial := skiNone;
  faction := NIL;
  fonkey := NIL;
  fKeyAction := kcNone;
end;

destructor TKeyHandler.Destroy;
begin
  inherited;
end;

procedure TKeyHandler.Execute;
begin
  if Assigned(faction) then
    faction.Execute;
  if assigned(fonkey) then
    fonkey(self);
end;

{ THotKeys }

function THotKeys.Add: integer;
begin
  result := fkeys.add(TKeyHandler.create);
end;

function THotKeys.Count: integer;
begin
  result := fkeys.Count;
end;

constructor THotKeys.Create;
begin
  inherited;
  fkeys := TObjectList<TKeyHandler>.create(true);
end;

destructor THotKeys.Destroy;
begin
  fkeys.clear;
  fkeys.free;
  inherited;
end;

function THotKeys.Exists(Special: TSpecialKeys; Enter, Trigger: Word): boolean;
var
  i : integer;
begin
  result := false;
  for I := 0 to fkeys.count-1 do
  begin
    if (fkeys[i].SpecialKey in Special) and (fkeys[i].Enterkey=enter) and (fkeys[i].Triggerkey=Trigger) then
    begin
      result := true;
      exit;
    end;
  end;
end;

function THotKeys.GetEnumerator: TEnumerator<TKeyHandler>;
begin
  result := fkeys.GetEnumerator;
end;

function THotKeys.GetItem(index: integer): TKeyHandler;
begin
  if (index >= 0) and (index < fkeys.count) then
    result := fkeys[index];
end;

Procedure THotKeys.Remove(index: integer);
begin
  if (index >= 0) and (index < fkeys.count) then
    fkeys.Delete(index);
end;

end.
