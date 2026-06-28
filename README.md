## What is this ?
This is a class for easily managing hotkeys (shortcuts). These are managed globally, rather than specifically
on a form or a control.

## Advantages
The hotkeys are defined once when the program starts. This ensures consistent keyboard navigation throughout the
entire application.
  
Another advantage is that you can use not only simple shortcuts (e.g., CTRL+T), but also
advanced key combinations (e.g., ALT+T T).

The action that is performed when a hotkey is pressed can be freely defined. Whether an "action" is executed,
whether you want to handle the whole thing via an event handler, or whether you want to send a message to a specific window
is up to the developer. A combination of these options is also possible.

## Define a hotkeys

Example:
`var HotId:integer;
begin
  HotId := Hotkeymanager.AddHotkey(Ord('F'),[mkControl]);
  HotKeyManager.AddHotKeyEvent(HotId,HotKeyProcedure);
end;
`
Thats all. *AddHotkey* adds a new Hotkey to the list. Parameters are just the Key (normal key) and a
set of modifier keys, that needs to pressed by the user, to trigger the hot key.
The *AddHotKeyEvent* attaches a event procedure to the hot key, that is triggert, when the user
presses the key(s).

## Start listening

After you defined your Hotkeys together with the actions, you only need to tell the Hotkeymanager,
that he should start reacting to the Hotkeys. This can be done with *Hotkeymanager.start()*;

More information about using the library can be found on the [wiki](https://github.com/UweRupprecht/PhoenixKeyboard/wiki)
