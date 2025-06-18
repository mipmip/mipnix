{pkgs,...}:
{
  home.packages = with pkgs; [
    (writeShellScriptBin "wrofi" ''
      session=`loginctl show-session $(awk '/tty/ {print $1}' <(loginctl)) -p Type | awk -F= '{print $2}'`
      if [ "${session}" -eq "x11"]; then
        ${pkgs.rofi}/bin/rofi -show drun -show-icons --allow-images --no-actions --gtk-dark --lines 6
      else
        ${pkgs.wofi}/bin/wofi --show=drun -show-icons --allow-images --no-actions --gtk-dark --lines 6
      fi
    '')
  ];

}
