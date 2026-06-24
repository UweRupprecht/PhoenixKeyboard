unit phk.manager;
(*
    Main Unit, that implements the hotkeymanager
*)
interface
uses
  winapi.windows,
  winapi.Messages,
  system.Classes,
  system.SysUtils,
  system.Generics.Collections,
  phk.general,
  phk.command,
  phk.keys,
  phk.Hotkeys;

Type
  //No T, because its a singelton
  HotkeyManager = Class
  strict private
      class var finstance : HotkeyManager;
  private
     fHotkeys : THotkeys;
     fHook    : HHook; //handle to the hook
     fKeystatemap : array[0..255] of boolean; //prevent from keyrepeat

     constructor Create;
     destructor Destroy;override;
     function HandleHookMessage(ncode:Integer;wParam:WPARAM;lParam:LPARAM):LResult;

     Procedure DoHotKey(Sender:TObject;Hotkey:THotkey;ACode:DWord;Modifier:phk_modifierkeys;var handled:boolean);
  protected
    class Procedure FreeInstance;
  public
    Class function Me:HotkeyManager;
    Procedure StartHooking;
    Procedure Stophooking;
  published
  End;

function KeyboardCallback(nCode:Integer;wParam: WPARAM;lParam:LPARAM):LResult;stdcall;

implementation

function KeyboardCallback(nCode:Integer;wParam: WPARAM;lParam:LPARAM):LResult;stdcall;
begin
  result := HotkeyManager.me.HandleHookMessage(nCode,wParam,lParam);
end;

{ HotkeyManager }

constructor HotkeyManager.Create;
begin
  inherited;
  fhotkeys := THotkeys.create;
end;

destructor HotkeyManager.Destroy;
begin
  fhotkeys.free;
  inherited;
end;

procedure HotkeyManager.DoHotKey(Sender: TObject; Hotkey: THotkey; ACode: DWord;
  Modifier: phk_modifierkeys; var handled: boolean);
var
  state :  THotKeyState;
begin
  handled := false;
  state := hotkey.HandleKeyStroke(ACode,Modifier);
  if (state = hkInMode) or (state = hkTrigger) then
    Handled := true;

end;

class procedure HotkeyManager.FreeInstance;
begin
  if (finstance.fHook <> 0) then
    finstance.Stophooking;
  if (finstance <> NIL) then
    FreeAndNil(finstance);
end;

function HotkeyManager.HandleHookMessage(ncode: Integer; wParam: WPARAM;
  lParam: LPARAM): LResult;
var
  pkh: PKBDLLHOOKSTRUCT;
  currentVK:DWord;
  currentMods : phk_ModifierKeys;
  key : THotKey;
  WasHandled : boolean;
begin
  if (nCode = HC_ACTION) then
  begin
    pkh := PKBDLLHOOKSTRUCT(lparam);
    CurrentVK := pkh^.vkCode;
    if (CurrentVK <= 255) then
    begin
      if (wParam = WM_KEYUP) or (wParam = WM_SYSKEYUP) then
        fKeyStateMap[CurrentVK] := false
      else //wm_keydown/wm_syskeydown
      begin
        if not fKeyStateMap[CurrentVK] then
        begin
          fKeyStateMap[CurrentVK] := true; //First-Time
          CurrentMods := GetModifierKeyStates;
          if fHotKeys.MatchHotkey(CurrentVK,CurrentMods,key) then
          begin
            WasHandled := false;
            TThread.Synchronize(NIL,Procedure
            begin
              DoHotKey(self,key,CurrentVK,CurrentMods,wasHandled);
            end
            );
            if WasHandled then
            begin
              result := 1;
              exit;
            end;
          end;
        end;
      end;
    end;
  end;
  Result := CallNextHookEx(fHook, nCode, wParam, lParam);
end;

class function HotkeyManager.Me: HotkeyManager;
begin
  if finstance = NIL then
    finstance := HotkeyManager.create;
  result := finstance;
end;

procedure HotkeyManager.StartHooking;
begin
  //Prevent multihooking
  if (fHook <> 0) then
    UnhookWindowsHookEx(fhook);
  fhook := SetWindowsHookEx(WH_KEYBOARD_LL,@KeyboardCallback,hInstance,0);
  if fhook = 0 then
    RaiseLastOsError;
end;

procedure HotkeyManager.Stophooking;
begin
  if fhook <> 0 then
  begin
    UnhookWindowsHookEx(fhook);
    fhook := 0;
  end;
end;

INITIALIZATION
  HotkeyManager.me;
FINALIZATION
  HotkeyManager.FreeInstance;
end.
