{ ... }:
{
  # Hyprland keybindings. This is the source: hypr/binds.conf is generated from
  # it, so a binding is declared once and reaches both the running compositor
  # and the cheatsheets.
  #
  # `app` is the cheatsheet section and is independent of the target: the
  # launcher keys are Hyprland bindings that read better under their own
  # heading, which is how the hand-written cheatsheet grouped them.
  #
  # `document = false` keeps a family member out of the cheatsheets when
  # another entry already covers it, such as the nine further workspace keys
  # behind "Switch to workspace 1 (idem for 2-9, 0 is 10)".
  flake.hotkeys = [

    { kind = "chord"; app = "Launchers"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "Return";
      action = ''exec, $terminal'';
      desc = "Terminal";
    }

    { kind = "chord"; app = "Launchers"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "Return";
      action = ''exec, $terminalDarkMode'';
      desc = "Terminal DarkMode";
    }

    { kind = "chord"; app = "Launchers"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "B";
      action = ''exec, $browser'';
      desc = "Firefox";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "Q";
      action = "killactive,";
      desc = "Kill Active";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "M";
      action = "exit,";
      desc = "Exit Hyprland";
    }

    { kind = "chord"; app = "Launchers"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "F";
      action = ''exec, $fileManager'';
      desc = "Files";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "W";
      action = "togglefloating,";
      desc = "Toggle Floating";
    }

    { kind = "chord"; app = "Launchers"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "S";
      action = "exec, myhotkeys";
      desc = "My Hotkeys (your looking at it)";
    }

    { kind = "chord"; app = "Launchers"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "space";
      action = "exec, walker";
      desc = "App launcher";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "alt" ]; key = "space";
      action = "exec, walker -m clipboard";
      desc = "Show clipboard history";
    }

    { kind = "chord"; app = "Launchers"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "A";
      action = "exec, nwg-panel";
      desc = "Quick settings";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "P";
      action = "pseudo,";
      desc = "PSEUDO";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "J";
      action = "layoutmsg, togglesplit";
      desc = "Toggle Split";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "ctrl_l" "shift" ]; key = "Right";
      action = "movewindow, r";
      desc = "Swap active window with right window";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "ctrl_l" "shift" ]; key = "Left";
      action = "movewindow, l";
      desc = "Swap active window with left window";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "ctrl_l" "shift" ]; key = "H";
      action = "movewindow, mon:l";
      desc = "Move active window to the left monitor";
      note = "Move active window to monitor left/right";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "ctrl_l" "shift" ]; key = "L";
      action = "movewindow, mon:r";
      desc = "Move active window to the right monitor";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "D";
      action = ''exec, gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" && ~/.config/hypr/scripts/theme-wallpaper dark'';
      desc = "Set darkmode";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "D";
      action = ''exec, gsettings set org.gnome.desktop.interface color-scheme "prefer-light" && ~/.config/hypr/scripts/theme-wallpaper light'';
      desc = "Set lightmode";
    }

    { kind = "chord"; app = "Launchers"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "S";
      action = ''exec, $signal'';
      desc = "Signal";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "L";
      action = "exec, pidof hyprlock || hyprlock";
      desc = "Lock screen";
      note = ''
        Lock screen.

        These resolve to hyprlock directly rather than to `loginctl lock-session`, so
        a manual lock still works if hypridle is not running. lock-session is a no-op
        with no error when no listener is registered, which would leave an unlocked
        screen behind and say nothing. hypridle's own lock_cmd is this same string,
        so both paths end up in one place without either depending on the other.
      '';
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "L";
      action = "exec, systemctl suspend";
      desc = "Lock screen and suspend";
      note = ''
        Suspend only. hypridle's before_sleep_cmd does the locking, and covers lid
        close and a hand-typed `systemctl suspend` at the same time. The old form was
        `hyprlock && systemctl suspend`, which suspended only AFTER the user had
        already come back and unlocked.
      '';
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "Tab";
      action = "workspace, previous";
      desc = "Switch to the previous workspace";
    }

    { kind = "chord"; app = "Launchers"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "ctrl_l" "shift" ]; key = "R";
      action = "exec, hyprshot -m region --silent -- ~/.config/hypr/scripts/shot-notify";
      desc = "Screenshot of region";
      note = ''
        Screenshots. Ctrl+Shift+R grabs a region, Ctrl+Shift+W a window, and
        Ctrl+Shift+E reveals the last capture in the file manager.

        --silent suppresses hyprshot's own notification: it is sent without any
        action, and the freedesktop spec only makes a notification clickable when it
        carries one, so clicking it can never do anything. Everything after `--` is
        hyprshot's post-save hook, called with the saved path; shot-notify sends the
        replacement notification and reveals the file when you click it.
      '';
    }

    { kind = "chord"; app = "Launchers"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "ctrl_l" "shift" ]; key = "W";
      action = "exec, hyprshot -m window --silent -- ~/.config/hypr/scripts/shot-notify";
      desc = "Screenshot of window";
    }

    { kind = "chord"; app = "Launchers"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "ctrl_l" "shift" ]; key = "E";
      action = "exec, ~/.config/hypr/scripts/shot-reveal-last";
      desc = "Reveal the last screenshot";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "Left";
      action = "movefocus, l";
      desc = "Move focus with Super and the arrow keys";
      note = "Move focus with mainMod + arrow keys";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "Right";
      action = "movefocus, r";
      desc = "Move focus right"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "Up";
      action = "movefocus, u";
      desc = "Move focus up"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "Down";
      action = "movefocus, d";
      desc = "Move focus down"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "F";
      action = "fullscreen";
      desc = "Fullscreen";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "1";
      action = "workspace, 1";
      desc = "Switch to workspace 1 (idem for 2-9, 0 is 10)";
      note = "Switch workspaces with mainMod + [0-9]";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "2";
      action = "workspace, 2";
      desc = "Switch to workspace 2"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "3";
      action = "workspace, 3";
      desc = "Switch to workspace 3"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "4";
      action = "workspace, 4";
      desc = "Switch to workspace 4"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "5";
      action = "workspace, 5";
      desc = "Switch to workspace 5"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "6";
      action = "workspace, 6";
      desc = "Switch to workspace 6"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "7";
      action = "workspace, 7";
      desc = "Switch to workspace 7"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "8";
      action = "workspace, 8";
      desc = "Switch to workspace 8"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "9";
      action = "workspace, 9";
      desc = "Switch to workspace 9"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "0";
      action = "workspace, 10";
      desc = "Switch to workspace 10"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "1";
      action = "movetoworkspace, 1";
      desc = "Move active window to space 1 (idem for 2-9)";
      note = "Move active window to a workspace with mainMod + SHIFT + [0-9]";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "2";
      action = "movetoworkspace, 2";
      desc = "Move active window to space 2"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "3";
      action = "movetoworkspace, 3";
      desc = "Move active window to space 3"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "4";
      action = "movetoworkspace, 4";
      desc = "Move active window to space 4"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "5";
      action = "movetoworkspace, 5";
      desc = "Move active window to space 5"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "6";
      action = "movetoworkspace, 6";
      desc = "Move active window to space 6"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "7";
      action = "movetoworkspace, 7";
      desc = "Move active window to space 7"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "8";
      action = "movetoworkspace, 8";
      desc = "Move active window to space 8"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "9";
      action = "movetoworkspace, 9";
      desc = "Move active window to space 9"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "0";
      action = "movetoworkspace, 10";
      desc = "Move active window to space 10"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "mouse_down";
      action = "workspace, e+1";
      desc = "Scroll through workspaces with Super and the wheel";
      note = "Scroll through existing workspaces with mainMod + scroll";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "mouse_up";
      action = "workspace, e-1";
      desc = "Previous workspace"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "mouse:272"; variant = "bindm";
      action = "movewindow";
      desc = "Move a window by dragging with Super";
      note = "Move/resize windows with mainMod + LMB/RMB and dragging";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "super" ]; key = "mouse:273"; variant = "bindm";
      action = "resizewindow";
      desc = "Resize a window by dragging with Super";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ ]; key = "mouse:274";
      action = "exec,";
      desc = "Middle click does nothing"; document = false;
      note = "disable middle click";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "Right";
      action = "resizeactive, 30 0";
      desc = "Resize the active window with Super + Shift and the arrows";
      note = "Resize windows with SHIFT + arrow keys";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "Left";
      action = "resizeactive, -30 0";
      desc = "Resize narrower"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "Up";
      action = "resizeactive, 0 -30";
      desc = "Resize shorter"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ "shift" "super" ]; key = "Down";
      action = "resizeactive, 0 30";
      desc = "Resize taller"; document = false;
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ ]; key = "XF86AudioRaiseVolume"; variant = "bindel";
      action = "exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
      desc = "Volume up";
      note = "Laptop multimedia keys for volume and LCD brightness";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ ]; key = "XF86AudioLowerVolume"; variant = "bindel";
      action = "exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      desc = "Volume down";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ ]; key = "XF86AudioMute"; variant = "bindel";
      action = "exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      desc = "Mute audio";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ ]; key = "XF86AudioMicMute"; variant = "bindel";
      action = "exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      desc = "Mute the microphone";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ ]; key = "XF86MonBrightnessUp"; variant = "bindel";
      action = "exec, brightnessctl -e4 -n2 set 5%+";
      desc = "Brightness up";
    }

    { kind = "chord"; app = "Hyprland"; target = "hyprland"; scopes = [ "desktop" ];
      mods = [ ]; key = "XF86MonBrightnessDown"; variant = "bindel";
      action = "exec, brightnessctl -e4 -n2 set 5%-";
      desc = "Brightness down";
    }
  ];
}
