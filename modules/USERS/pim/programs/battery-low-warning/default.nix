{ ... }:
{
  flake.modules.homeManager.pim-battery-low-warning = { pkgs, ... }: {
    systemd.user.services.battery-low-warning = {
      Unit = {
        Description = "Notify when the battery runs low";
        PartOf = [ "default.target" ];
      };
      Service = {
        ExecStart = "${pkgs.writeShellApplication {
          name = "battery-low-warning";
          runtimeInputs = [ pkgs.coreutils pkgs.libnotify ];
          text = ''
            battery=""
            for candidate in /sys/class/power_supply/BAT*; do
              if [ -r "$candidate/capacity" ]; then
                battery="$candidate"
                break
              fi
            done

            if [ -z "$battery" ]; then
              exit 0
            fi

            warned_low=0
            warned_critical=0

            while :; do
              status="$(cat "$battery/status")"
              capacity="$(cat "$battery/capacity")"

              if [ "$status" = "Discharging" ]; then
                if [ "$capacity" -le 5 ] && [ "$warned_critical" -eq 0 ]; then
                  notify-send -a battery -u critical -i battery-caution \
                    "Battery critical (''${capacity}%)" \
                    "Plug in the charger now. The laptop hibernates at 2%."
                  warned_critical=1
                  warned_low=1
                elif [ "$capacity" -le 15 ] && [ "$warned_low" -eq 0 ]; then
                  notify-send -a battery -u normal -i battery-low \
                    "Battery low (''${capacity}%)" \
                    "Plug in the charger soon."
                  warned_low=1
                fi
              else
                warned_low=0
                warned_critical=0
              fi

              sleep 30
            done
          '';
        }}/bin/battery-low-warning";
        Restart = "on-failure";
        RestartSec = 30;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
