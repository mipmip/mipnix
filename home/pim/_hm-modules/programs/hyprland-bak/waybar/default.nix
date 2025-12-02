{config, lib, pkgs, ...}:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    systemd.target = "hyprland-session.target";
    settings = {
      mainBar = {
        layer = "top";
        height = 25;
        spacing = 10;
        modules-left = ["clock" "hyprland/workspaces"];
        modules-center = ["hyprland/window"];
        modules-right =["tray" "pulseaudio" "bluetooth" "network" "battery" "power-profiles-daemon"];

        "hyprland/workspaces" = {
          disable-scroll = true;
          format = "{icon} ";
          format-icons = {
            # Monitor 1
            "1" = "";
            "2" = "󰈹";
            "3" = "";
            "4" = "󰌨";
            "5" = "";
            # Monitor 2
            "11" = "";
            "12" = "󰈹";
            "13" = "";
            "14" = "";
            #active = "";
            default = "";
          };
        };

        network = {
          # interface: "wlp2s0", // (Optional) To force the use of this interface
          format-wifi = "   {essid} ({signalStrength}%)";
          format-ethernet = "   {ifname}";
          format-disconnected = "⚠  Disconnected";
          on-click = "nm-connection-editor";
        };

        pulseaudio = {
          format = "{icon}   {volume}%";
          format-bluetooth = "{icon}   {volume}%";
          format-muted = " ";
          format-icons = {
              default = ["" ""];
          };
          on-click = "pavucontrol";
        };

        bluetooth = {
          format-on = "󰂯";
          format-off = "󰂲";
          format-disabled = "󰂲";
          format-connected-battery = "{device_battery_percentage}% 󰂯";
          #format-alt = "{device_alias} 󰂯";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\n{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\n{device_address}\n{device_battery_percentage}%";
          on-click = "blueberry";
        };

        "hyprland/window" = {
          max-length = 50;
        };

        battery = {
          interval = 15;
          format = "{capacity}% {icon}";
          format-icons = ["󰁺" "󰁽" "󰁿" "󰂀" "󰁹"];
          format-charging = "{capacity}% 󰂄";
          format-plugged = "{capacity}% 󰂅";
          full-at = 95;
          states = {
            "good" = 90;
            "warning" = 30;
            "critical" = 15;
          };
        };

        power-profiles-daemon = {
          format = "{icon} ";
          tooltip-format = "Power profile: {profile}\nDriver: {driver}";
          tooltip = true;
          format-icons = {
            default = "";
            performance = "";
            balanced = "";
            power-saver = "";
          };
        };

        clock = {
          format-alt = "{:%a, %d. %b  %H:%M}";
        };

        tray = {
          spacing = 10;
        };
      };
    };
    style = ''
      /* Gruvbox colors */
      @define-color bg0_h #1d2021;
      @define-color bg0 #282828;
      @define-color bg1 #3c3836;
      @define-color bg2 #504945;
      @define-color bg3 #665c54;
      @define-color bg4 #7c6f64;
      @define-color fg0 #fbf1c7;
      @define-color fg1 #ebdbb2;
      @define-color fg2 #d5c4a1;
      @define-color fg3 #bdae93;
      @define-color fg4 #a89984;
      @define-color red #cc241d;
      @define-color green #98971a;
      @define-color yellow #d79921;
      @define-color blue #458588;
      @define-color purple #b16286;
      @define-color aqua #689d6a;
      @define-color orange #d65d0e;
      @define-color gray #928374;

      * {
        border: none;
        border-radius: 0;
        font-family: "Source Code Pro", "Font Awesome 6 Free";
        font-size: 14px;
        min-height: 0;
        transition-duration: 0.3s;
      }

      window#waybar {
        background: @bg0;
        color: @fg1;
        border-bottom: 2px solid @bg1;
        padding: 0 10px; /* Add horizontal padding to the entire bar */
      }

      tooltip {
        background: @bg0_h;
        border: 2px solid @bg4;
        border-radius: 6px;
      }

      tooltip label {
        color: @fg1;
      }

      #workspaces {
        background: @bg1;
        border-radius: 6px;
        margin: 5px 5px;
        padding: 0 6px;
      }

      #workspaces button.active {
        color: @green;
      }

      #workspaces button {
        padding: 0 7px;
        color: @fg3;
        border-radius: 4px;
        margin: 4px 2px;
      }

      #workspaces button:hover {
        background: @bg2;
        color: @fg1;
      }

      #window {
        margin: 0 5px;
        padding: 0 10px;
        border-radius: 6px;
        background: @bg1;
        color: @fg1;
      }

      #tray {
        background: @bg1;
        margin: 5px 5px;
        padding: 0 10px;
        border-radius: 6px;
      }

      #pulseaudio {
        background: @blue;
        color: @bg0_h;
        margin: 5px 0;
        padding: 0 10px;
        border-radius: 6px;
      }

      #pulseaudio.muted, #pulseaudio.source-muted {
        background: @bg2;
        color: @fg3;
      }

      #bluetooth {
        background: @purple;
        color: @bg0_h;
        margin: 5px 0;
        padding: 0 10px;
        border-radius: 6px;
      }

      #bluetooth.off, #bluetooth.disabled {
        background: @bg2;
        color: @fg3;
      }

      #network {
        background: @green;
        color: @bg0_h;
        margin: 5px 0;
        padding: 0 10px;
        border-radius: 6px;
      }

      #network.disconnected {
        background: @red;
      }

      #battery {
        background: @aqua;
        color: @bg0_h;
        margin: 5px 0 5px 0;
        padding: 0 10px;
        border-radius: 6px;
      }

      #power-profiles-daemon {
        background: @aqua;
        color: @bg0_h;
        margin: 5px 5px 5px 0;
        padding: 0 10px;
        border-radius: 6px;
      }

      #battery.warning {
        background: @yellow;
      }

      #battery.critical {
        background: @red;
      }

      #battery.charging {
        background: @green;
      }

      #clock {
        background: @orange;
        color: @bg0_h;
        margin: 5px 0 5px 5px;
        padding: 0 10px;
        border-radius: 6px;
      }
    '';
  };
}
