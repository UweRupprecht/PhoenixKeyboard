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
     fHookMode : THookMode;

     constructor Create;
     destructor Destroy;override;

     function HandleGlobalHookMessage(ncode:Integer;wParam:WPARAM;lParam:LPARAM):LResult;
     function HandleLocalHookMessage(nCode:integer;wParam:WPARAM;lParam:LPARAM):LResult;
     Procedure DoHotKey(Sender:TObject;Hotkey:THotkey;ACode:DWord;Modifier:phk_modifierkeys;var handled:boolean);
  protected
    class Procedure FreeInstance;
    function CheckHotId(HotId:integer):boolean;
  public
    //Starts listening;Mode is the listening mode;
    //hmLocal = Based upon application thread (default)
    //hmLocal = Global listening
    Procedure Start(Mode:THookmode=hmLocal);
    //Stops listening; Can be used to pause the listening on critical parts
    //automatically called, when instance is freed
    Procedure Stop;
    //Checks if the manager is listening
    function IsListening:boolean;

    //Defining Hotkeys and there actions
    //Its based on the HotID which identifies a Hotkey

    //Adds a new Hotkey to the list of hotkeys
    //Keycode is the virtual key code for the keystroke
    //Modifiers is a set of modifier keys (shift,control....)
    //Returns the HotId of the new Hotkey
    function AddHotkey(Keycode:dWord;Modifiers:phk_modifierkeys):integer;
    //Adds another keystroke to an existing Hotkey
    //HotID is the id of the existing hotkey
    //Keycode is the virtual key code of the key
    //Modifiers is a set of modifier keys
    Procedure AddKeyStroke(HotID:integer;KeyCode:DWord;Modifiers:phk_modifierkeys);
    //Disables/enables a hotkey
    //HotID is the ID of an existing Hotkey
    //disable = disable/enable hotkey
    Procedure DisableHotKey(HotID:integer;disable:boolean=true);
    //Removes a Hotkey from the Hotkeylist
    //Hotid is the ID of the Hotkey to delete
    //returns true on success
    function RemoveHotkey(HotID:integer):boolean;

    //Adds the "Action" to the Hotkey
    //Using a eventhandler
    Procedure AddHotkeyEvent(HotID:Integer;Proc:TNotifyCommand);
    //Using a Action (TBasicAction)
    Procedure AddHotkeyAction(HotID:Integer;Action:TBasicAction);
    //Using SendMessage WM_PHKHOTKEY to the targetwindow
    Procedure AddHotkeyMessage(HotID:Integer;TargetWindow:HWND);



    Property Mode: THookMode read fHookmode;
  published
  End;

function KeyboardCallback(nCode:Integer;wParam: WPARAM;lParam:LPARAM):LResult;stdcall;

Var
  HotkeyManager:THotkeyManager;

implementation

function KeyboardCallback(nCode:Integer;wParam: WPARAM;lParam:LPARAM):LResult;stdcall;
begin
  if (HotKeyManager.fHookMode = hmGlobal) then
    result := HotkeyManager.HandleGlobalHookMessage(nCode,wParam,lParam);
  if (HotkeyManager.fHookMode = hmLocal) then
    result := HotkeyManager.HandleLocalHookMessage(nCode,wParam,lParam);
end;


{ HotkeyManager }

function THotkeyManager.AddHotkey(Keycode: dWord;
  Modifiers: phk_modifierkeys): integer;
begin
  result := fHotkeys.Add;
  fhotkeys.HotKey[result].AddKey(KeyCode,Modifiers);
end;

procedure THotkeyManager.AddHotkeyAction(HotID: Integer; Action: TBasicAction);
begin
  if CheckHotId(HotID)then
    fhotkeys.Hotkey[HotId].AddActionCommand(Action);
end;

procedure THotkeyManager.AddHotkeyEvent(HotID: Integer; Proc: TNotifyCommand);
begin
  if CheckHotId(HotID)then
    fhotkeys.Hotkey[HotId].AddEventCommand(proc);
end;

procedure THotkeyManager.AddHotkeyMessage(HotID: Integer; TargetWindow: HWND);
begin
  if CheckHotId(HotID)then
    fhotkeys.Hotkey[HotId].AddMessageCommand(TargetWindow);
end;

procedure THotkeyManager.AddKeyStroke(HotID: integer; KeyCode: DWord;
  Modifiers: phk_modifierkeys);
begin
  if CheckHotID(HotID) then
    fhotkeys.HotKey[hotid].AddKey(KeyCode,Modifiers);
end;

function THotkeyManager.CheckHotId(HotId: integer): boolean;
begin
  result := (HotId >= 0) and (HotId < fHotkeys.count);
end;

constructor THotkeyManager.Create;
begin
  inherited;
  fhotkeys := THotkeys.create;
  fHookMode := hmLocal;
end;

destructor THotkeyManager.Destroy;
begin
  fhotkeys.free;
  inherited;
end;

procedure THotkeyManager.DisableHotKey(HotID: integer; disable: boolean);
begin
  if CheckHotId(HotId) then
    fhotkeys.HotKey[HotId].Disable := disable;
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
    HotkeyManager.Stop;
  if (HotkeyManager <> NIL) then
    FreeAndNil(HotkeyManager);
end;

function THotkeyManager.HandleGlobalHookMessage(ncode: Integer; wParam: WPARAM;
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


function THotkeyManager.HandleLocalHookMessage(nCode: integer; wParam: WPARAM;
  lParam: LPARAM): LResult;
var
  currentVK:DWord;
  currentMods : phk_ModifierKeys;
  isKeyUp : boolean;
  WasHandled,generalHandled : boolean;
begin
  if nCode >= 0 then
  begin
    isKeyUp := (Lparam and $80000000) <> 0;
    currentVK := wParam;
    if (CurrentVK >= cMinKey) and (currentVK <= cMaxKey) then
    begin
      if isKeyUp then
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
  result := CallNextHookEx(fhook,ncode,wparam,lparam);
end;

function THotkeyManager.IsListening: boolean;
begin
  result := (fhook <> 0);
end;

function THotkeyManager.RemoveHotkey(HotID: integer): boolean;
begin
  result := false;
  if CheckHotId(HotID) then
    result := fhotkeys.Delete(HotId);
end;

procedure THotkeyManager.Start(Mode:THookMode);
begin
  //Prevent multihooking
  if (fHook <> 0) then
  begin
    UnhookWindowsHookEx(fhook);
    fhook := 0;
  end;
  fhookMode := Mode;
  if (fHookMode = hmLocal) then
    fhook := SetWindowsHookEx(WH_KEYBOARD,@KeyboardCallback,0,GetCurrentThreadID())
  else
    fhook := SetWindowsHookEx(WH_KEYBOARD_LL,@KeyboardCallback,hInstance,0);
  if fhook = 0 then
    RaiseLastOsError;
end;

procedure THotkeyManager.Stop;
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
