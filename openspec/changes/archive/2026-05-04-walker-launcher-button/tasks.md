# Tasks: Walker Launcher Button

## 1. Update Bar Widget

- [x] 1.1 Replace the start button label from "Welcome to pims AGS!" to the 󱗼 nerd font icon
- [x] 1.2 Change `onClicked` handler to call `execAsync("walker")`
- [x] 1.3 Set `halign={Gtk.Align.START}` and remove `hexpand` from the start button

## 2. Style the Launcher Button

- [x] 2.1 Add a CSS class name to the launcher button (e.g., `class="AppLauncher"`)
- [x] 2.2 Add hover and active state styles in `style.scss`
- [x] 2.3 Add appropriate padding so the icon has comfortable click area

## 3. Verify

- [x] 3.1 Run `ags run .` and confirm the button appears top-left
- [x] 3.2 Click the button and confirm walker opens
- [x] 3.3 Confirm hover/active visual feedback works
