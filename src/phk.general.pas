unit phk.general;
(*
  LICENSE: MIT (see LICENSE file)

  Purpose: global types, constants and functions used within the library
*)
interface
uses
  winapi.windows,
  winapi.Messages,
  system.classes,
  System.UITypes;
const
   //Windows message send to defined window, when using
   //commandmessage on a command
   WM_PHKHOTKEY = WM_USER+9000;
type
  //Keys called modifierkey when the modify the meaning of a nother key
  //Example: A Key normaly produce "a", together with Shift it produces "A"
  //mkNumLock used to diff normal keys form the numpad keys
  //mkScroll might be used also for diff;More investiagtion needed

  phk_modifierkey = (mkNone, mkLShift, mkRShift, mkShift, mkLControl, mkRControl, mkControl,
    mkLAlt, mkRAlt, mkAlt, mkLWin, mkRWin, mkWin, mkScroll, mkNumLock);

  //Set of as their can be multiple pressed at a time
  phk_ModifierKeys = set of phk_modifierkey;

  //Api-struct for hook
  PKBDLLHOOKSTRUCT = ^KBDLLHOOKSTRUCT;
  KBDLLHOOKSTRUCT = Record
    vkCode : DWORD;
    scanCode : DWORD;
    flags: DWord;
    time : DWord;
    dwExtra : ULONG_PTR;
  End;

  //Helper record for defining "normal" keys
  TKeyArea = Record
               AreaBegin : DWord;
               AreaEnd   : DWord;
               function InArea(Code:DWord):boolean;
  End;

//Defined "normal" keys to use; restricts hook to handle
//only keystrokes with this codes
const
  //Keys "0" - "9"
  cNumKeys : TKeyArea = (AreaBegin:$39;AreaEnd:$39);
  //Keys "A" - "Z"
  cAlphaKeys : TKeyArea = (AreaBegin:$41;AreaEnd:$5A);
  //Keys "Num0" - "NumDivide"
  cNumPadKeys : TKeyArea = (AreaBegin:$5F;AreaEnd:$6F);
  //Keys "F1" - "F24"
  cFunctionKeys : TKeyArea = (AreaBegin:$70;AreaEnd:$87);
  //Mapping for modifiers from/to Virtual Key Codes used on API
  cMinKey : DWord = $39;
  cMaxKey : DWord = $87;


  //Virtual key codes for the modifier keys
const
  cPhk_ModifierKeyCodes: array[phk_modifierkey] of DWord = (
    0,           //value for None
    vkLShift,
    vkRShift,
    vkShift,
    vkLControl,
    vkRControl,
    vkControl,
    vkLMenu,
    vkRMenu,
    vkMenu,
    vkLWin,
    vkRWin,
    0,           //vkWin has to be setup manually
    vkScroll,
    vkNumLock
    );

type
  //state of a hotkey
  //ksNone = default; not disabled and also not pressed
  //ksDisabled = Disabled; No matching needed
  //ksPressed = was already pressed or is pressed
  TKeyState = (ksNone,ksDisabled,ksPressed);
  //basic record for storing infos on a keystroke
  TKeyData = Record
               Code : DWord; //Virtual Key code
               Modifier : phk_ModifierKeys; //Modifier keys
               State : TKeyState;
               Class Operator Initialize(out value:TKeyData);
  End;

Type
  //Helpers for handling the Sendmessage on FMX-APPS
  //Defines the onMessage event type
  TFMXOnMessage = Procedure (var msg:TMessage) of Object;
  //Helper window, to handle WM_PHKHOTKEY messages on FMX
  TFMXHelperWindow = Class
  private
    fHandle : HWND;
    fonMessage : TFMXOnMessage;
  protected
     Procedure WndProc(var message:TMessage);
  public
    Constructor create;
    Destructor Destroy;override;
  published
    Property Handle:HWND read fhandle;
    Property onMessage : TFMXOnMessage read fonMessage write fonMessage;
  End;

//Calls GetAsyncKeyState for each modifierkey (if needed)
function GetModifierKeyStates: phk_ModifierKeys;
//Get the string representation of a modifier keys set
function ModifierToString(Modifier:phk_Modifierkeys):string;
//compares two modifier-sets;
//result is true, when one of the FromHook-items is in the Defined Set
function ModifierCompare(FromHook:PHK_MODIFIERKEYS;Defined:PHK_MODIFIERKEYS):boolean;
implementation
{ TPHK_KeyData }

class operator TKeyData.Initialize(out value: TKeyData);
begin
  value.Code := 0;
  value.Modifier := [];
  value.State := ksNone;
end;

function GetModifierKeyStates: phk_ModifierKeys;
var
  i: phk_modifierkey;

begin
  result := [mkNone];
  for i := Low(phk_modifierkey) to High(phk_modifierkey) do
  begin
    if cPhk_ModifierKeyCodes[i] > 0 then
      if (GetAsyncKeyState(cPhk_ModifierKeyCodes[i]) and $8000) <> 0 then
      begin
        Exclude(result,mkNone);
        Include(result, i);
      end;
  end;
  if (mkLWin in result) or (mkRWin in result) then
  begin
    Exclude(result,mkNone);
    Include(result, mkWin);
  end;
end;

function ModifierToString(Modifier:phk_Modifierkeys):string;
begin
  result := '[';
  if (mkNone in Modifier) then result := result+'None,';
  if (mkLShift in Modifier) then result := result+'LShift,';
  if (mkRShift in Modifier) then result := result+'RShift,';
  if (mkShift in Modifier) then result := result+'Shift,';
  if (mkLControl in Modifier) then result := result+'LControl,';
  if (mkRControl in Modifier) then result := result+'RControl,';
  if (mkControl in Modifier) then result := result+'Control,';
  if (mkLAlt in Modifier) then result := result+'LAlt,';
  if (mkRAlt in Modifier) then result := result+'RAlt,';
  if (mkAlt in Modifier) then result := result+'Alt,';
  if (mkLWin in Modifier) then result := result+'LWin,';
  if (mkRWin in Modifier) then result := result+'RWin,';
  if (mkWin in Modifier) then result := result+'Win,';
  if (mkScroll in Modifier) then result := result+'Scroll,';
  if (mkNumLock in Modifier) then result := result+'NumLock,';
  result := copy(result,0,length(result)-1)+']';
end;

function ModifierCompare(FromHook:PHK_MODIFIERKEYS;Defined:PHK_MODIFIERKEYS):boolean;
var
  i : PHK_MODIFIERKEY;
begin
  result := False;
  for I := Low(PHK_MODIFIERKEY) to High(PHK_MODIFIERKEY) do
    if (i in Defined) and (i in FromHook) then
    begin
      result := true;
      exit;
    end;
end;
{ TKeyArea }

function TKeyArea.InArea(Code: DWord): boolean;
begin
  result := (code >= AreaBegin) and (code <= AreaEnd);
end;

{ TFMXHelperWindow }

constructor TFMXHelperWindow.create;
begin
  inherited create;
  fHandle := AllocateHwnd(WndProc);
end;

destructor TFMXHelperWindow.Destroy;
begin
  DeallocateHwnd(fhandle);
  inherited;
end;

procedure TFMXHelperWindow.WndProc(var message: TMessage);
begin
  if message.Msg = WM_PHKHOTKEY then
  begin
    if assigned(fonMessage) then
      fonMessage(Message);
  end;
end;

end.

