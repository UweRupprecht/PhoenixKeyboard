unit phk.general;
(*
    global definition and types used in the lib
*)
interface
uses
  winapi.windows,
  System.UITypes;
type
  //Keys called modifierkey when the modify the meaning of a nother key
  //Example: A Key normaly produce "a", together with Shift it produces "A"
  //mkNumLock used to diff normal keys form the numpad keys
  //mkScroll might be used also for diff;More investiagtion needed
  phk_modifierkey = (mkNone, mkLShift, mkRShift, mkShift, mkLControl, mkRControl, mkControl,
    mkLAlt, mkRAlt, mkAlt, mkLWin, mkRWin, mkWin, mkFnc, mkScroll, mkNumLock);
  //Set of as their can be multiple pressed at a time
  phk_ModifierKeys = set of phk_modifierkey;

  //Mapping for modifiers from/to Virtual Key Codes used on API
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
    vkFunction,
    vkScroll,
    vkNumLock
    );
type
  TKeyState = (ksNone,ksDisabled,ksPressed);
  TKeyData = Record
               Code : DWord; //Virtual Key code
               Modifier : phk_ModifierKeys; //Modifier keys
               State : TKeyState;

               Class Operator Initialize(out value:TKeyData);
  End;


//Calls GetAsyncKeyState for each modifierkey (if needed)
function GetModifierKeyStates: phk_ModifierKeys;

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
        Include(result, i);
  end;
  if (mkLWin in result) or (mkRWin in result) then
    Include(result, mkWin);
end;

end.

