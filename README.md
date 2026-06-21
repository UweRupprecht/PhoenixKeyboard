## What is this ?
This is a class for easily managing hotkeys (shortcuts). These are managed globally, rather than specifically
on a form or a control.

## Advantages
The hotkeys are defined once when the program starts. This ensures consistent keyboard navigation throughout the
entire application.

<<<<<<< HEAD
Another advantage is that you can use not only simple shortcuts (e.g., CTRL+T), but also
advanced key combinations (e.g., ALT+T T).
=======
`#ff0000` Features:
>>>>>>> 2f1193310fc9624f96eb387c5ccc3a3390029cc3

The action that is performed when a hotkey is pressed can be freely defined. Whether an "action" is executed,
whether you want to handle the whole thing via an event handler, or whether you want to send a message to a specific window
is up to the developer. A combination of these options is also possible.

### Roadmap
V.1.0.0
- Finalize Core Developement

V.1.5.0
- Define Hotkeys by Strings (like "ALT+T T")
- improve custom data handling
