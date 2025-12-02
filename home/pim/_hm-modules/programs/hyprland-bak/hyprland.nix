{ config, lib, pkgs, username, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    plugins = [ pkgs.hyprlandPlugins.hyprsplit ];

    settings = {
      ################
      ### MONITORS ###
      ################

      # See https://wiki.hyprland.org/Configuring/Monitors/
      # Monitor config is done by nwg-displays
      #source = "/home/${username}/.config/hypr/monitors.conf";

      # See https://wiki.hyprland.org/Configuring/Monitors/
      # framework mon: 0.66667, 1.166667, 1.175, 1.26667,1.333333,1.566667
      #set if lego1
      #monitor= ",preferred,auto,1.566667";

      ###################
      ### MY PROGRAMS ###
      ###################

      # See https://wiki.hyprland.org/Configuring/Keywords/

      # Set programs that you use
      "$terminal" = "ghostty";
      "$fileManager" = "nautilus";
      "$menu" = "wofi --show drun";
      "$browser" = "firefox";
      "$music" = "spotify";

      #################
      ### AUTOSTART ###
      #################

      exec-once = [
        "[workspace 1 silent] $terminal"
        "[workspace 2 silent] $browser"
        "[workspace 3 silent] $music"
        "swayosd-server"
        "swayosd-libinput-backend"
        "swaync"
        "clipse -listen"
      ];

      #############################
      ### ENVIRONMENT VARIABLES ###
      #############################

      #      env = [
      #        "XCURSOR_SIZE,104"
      #        "HYPRCURSOR_SIZE,24"
      #      ];
      #
      #####################
      ### LOOK AND FEEL ###
      #####################


      general = {
        gaps_in = 5;
        gaps_out = 8;
        border_size = 2;

        "col.active_border" = "rgba(a89984cc) rgba(7c6f64cc) 45deg";
        "col.inactive_border" = "rgba(282828aa)";

        resize_on_border = false;

        allow_tearing = false;

        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 1.0;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      animations = {
        enabled = "yes, please :)";

        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];

        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };

      dwindle = {
        pseudotile = true; # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = true; # You probably want this
      };

      master = {
        new_status = "master";
      };

      misc = {
        force_default_wallpaper = -1; # Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = true; # If true disables the random hyprland logo / anime girl background. :(
      };

      xwayland = {
        force_zero_scaling = false;
      };

      #############
      ### INPUT ###
      #############

      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";

        follow_mouse = 1;
        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

        touchpad = {
          natural_scroll = true;
          scroll_factor = 0.5;
        };
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_distance = 1000;
      };

      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      plugin = {
        hyprsplit = {
          num_workspaces = 10;
        };
      };

      ###################
      ### KEYBINDINGS ###
      ###################

      ##### COMPUTER DEP ######
      "$mainMod" = "ALT"; # Sets "Windows" key as main modifier
      "$mainAlt" = "SUPER"; # Sets "Windows" key as main modifier

      bind = [
        # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more

        "$mainMod, P, pseudo, # dwindle"
        "$mainMod, E, togglesplit, # dwindle"

        "$mainMod, return, exec, $terminal"
        "$mainMod, B, exec, $browser"
        "$mainMod SHIFT, F, exec, $fileManager"
        "$mainMod SHIFT, L, exec, hyprlock"

        "$mainAlt, space, exec, $terminal --class clipse -e clipse"
        "$mainMod, space, exec, $menu"
        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, V, togglefloating,"
        "$mainMod, P, pseudo,"
        "$mainMod, F, fullscreen"

        # Move focus with mainMod + arrow keys
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"


        "$mainMod $mainAlt, S, exec, hyprshot -m window"
        "$mainMod SHIFT, S, exec, hyprshot -m region"

        # power-profiles-daemon
        "$mainMod+Ctrl+Shift, W, exec, powerprofilesctl set power-saver"
        "$mainMod+Ctrl+Shift, E, exec, powerprofilesctl set balanced"
        "$mainMod+Ctrl+Shift, R, exec, powerprofilesctl set performance"

        # Focus to other window
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Move to workspace
        "$mainMod, 1, split:workspace, 1"
        "$mainMod, 2, split:workspace, 2"
        "$mainMod, 3, split:workspace, 3"
        "$mainMod, 4, split:workspace, 4"
        "$mainMod, 5, split:workspace, 5"
        "$mainMod, 6, split:workspace, 6"
        "$mainMod, 7, split:workspace, 7"
        "$mainMod, 8, split:workspace, 8"
        "$mainMod, 9, split:workspace, 9"
        "$mainMod, 0, split:workspace, 10"

        # Move application to workspace
        "$mainMod SHIFT, 1, split:movetoworkspace, 1"
        "$mainMod SHIFT, 2, split:movetoworkspace, 2"
        "$mainMod SHIFT, 3, split:movetoworkspace, 3"
        "$mainMod SHIFT, 4, split:movetoworkspace, 4"
        "$mainMod SHIFT, 5, split:movetoworkspace, 5"
        "$mainMod SHIFT, 6, split:movetoworkspace, 6"
        "$mainMod SHIFT, 7, split:movetoworkspace, 7"
        "$mainMod SHIFT, 8, split:movetoworkspace, 8"
        "$mainMod SHIFT, 9, split:movetoworkspace, 9"
        "$mainMod SHIFT, 0, split:movetoworkspace, 10"

        "$mainMod, D, split:swapactiveworkspaces, current +1"
        "$mainMod, G, split:grabroguewindows"
        #
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindel = [
        ",XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise 0"
        ",XF86AudioLowerVolume, exec, swayosd-client --output-volume lower 0"
        ",XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, swayosd-client --brightness=raise 10"
        ",XF86MonBrightnessDown, exec, swayosd-client --brightness=lower 10"
        ",Caps_Lock, exec, swayosd-client --caps-lock"
      ];

      bindl = [
        ",XF86AudioNext, exec, playerctl next"
        ",XF86AudioPause, exec, playerctl play-pause"
        ",XF86AudioPlay, exec, playerctl play-pause"
        ",XF86AudioPrev, exec, playerctl previous"
      ];

      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        "float, class:org.gnome.Nautilus"
        "float, class:org.pulseaudio.pavucontrol"
        "float, class:nwg-displays, title:nwg-displays"
        "float, class:ddcui"
        "float, class:blueberry.py"
        "size 50% 50%, class:nwg-displays, title:nwg-displays"
        "float, class:(clipse)"
        "size 622 652, class:(clipse)"
        "stayfocused, class:(clipse)"
      ];
    };
  };
}
