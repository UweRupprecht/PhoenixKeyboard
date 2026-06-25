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
{$IFDEF DEBUG}
  CodeSiteLogging,
{$ENDIF}
  phk.Hotkeys;

Type
  //Switch to global variable instead of class var
  //Do not create an instance of this class as it is implemented as singleton
  THotkeyManager = Class
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
    Procedure StartHooking;
    Procedure Stophooking;

    Property Hotkeys : THotKeys read fHotkeys;
  published
  End;

function KeyboardCallback(nCode:Integer;wParam: WPARAM;lParam:LPARAM):LResult;stdcall;

Var
  HotkeyManager:THotkeyManager;

implementation

function KeyboardCallback(nCode:Integer;wParam: WPARAM;lParam:LPARAM):LResult;stdcall;
begin
  result := HotkeyManager.HandleHookMessage(nCode,wParam,lParam);
end;

{ HotkeyManager }

constructor THotkeyManager.Create;
begin
  inherited;
  fhotkeys := THotkeys.create;
end;

destructor THotkeyManager.Destroy;
begin
  fhotkeys.free;
  inherited;
end;

procedure THotkeyManager.DoHotKey(Sender: TObject; Hotkey: THotkey; ACode: DWord;
  Modifier: phk_modifierkeys; var handled: boolean);
var
  state :  THotKeyState;
begin
  handled := false;
  state := hotkey.HandleKeyStroke(ACode,Modifier);
  if (state = hkInMode) or (state = hkTrigger) then
    Handled := true;
end;

class procedure THotkeyManager.FreeInstance;
begin
  if (HotkeyManager.fHook <> 0) then
    HotkeyManager.Stophooking;
  if (HotkeyManager <> NIL) then
    FreeAndNil(HotkeyManager);
end;

function THotkeyManager.HandleHookMessage(ncode: Integer; wParam: WPARAM;
  lParam: LPARAM): LResult;
var
  pkh: PKBDLLHOOKSTRUCT;
  currentVK:DWord;
  currentMods : phk_ModifierKeys;
  WasHandled,generalHandled : boolean;
begin
  if (nCode = HC_ACTION) then
  begin
    pkh := PKBDLLHOOKSTRUCT(lparam);
    CurrentVK := pkh^.vkCode;
    //Spead up a bit; only keys $39 ("0") or $87 ("F24") are relevant
    if (CurrentVK >= cMinKey) and (currentVK <= cMaxKey) then
    begin
      if (wParam = WM_KEYUP) or (wParam = WM_SYSKEYUP) then
      begin
        fKeyStateMap[CurrentVK] := false;
      end
      else //wm_keydown/wm_syskeydown
      begin
        if not fKeyStateMap[CurrentVK] then
        begin
          CurrentMods := GetModifierKeyStates;
          fKeyStateMap[CurrentVK] := true; //First-Time
          //Need to be redesigned, cause multiple Hotkeys might be triggert
          GeneralHandled := false;
          for var key in fhotkeys do
          begin
            if key.MatchKey(CurrentVK,CurrentMods) then
            begin
              WasHandled := false;
              TThread.Synchronize(NIL,Procedure
              begin
                DoHotKey(self,key,CurrentVK,CurrentMods,wasHandled);
              end
              );
              if WasHandled then GeneralHandled := true;

            end;
          end;
          if GeneralHandled then
          begin
            result := 1;
            exit;
          end;
        end;
      end;
    end;
  end;
  Result := CallNextHookEx(fHook, nCode, wParam, lParam);
end;


procedure THotkeyManager.StartHooking;
begin
  //Prevent multihooking
  if (fHook <> 0) then
    UnhookWindowsHookEx(fhook);
  fhook := SetWindowsHookEx(WH_KEYBOARD_LL,@KeyboardCallback,hInstance,0);
  if fhook = 0 then
    RaiseLastOsError;
end;

procedure THotkeyManager.Stophooking;
begin
  if fhook <> 0 then
  begin
    UnhookWindowsHookEx(fhook);
    fhook := 0;
  end;
end;

INITIALIZATION
  HotkeyManager := THotkeyManager.create;
FINALIZATION
  HotkeyManager.FreeInstance;
end.
