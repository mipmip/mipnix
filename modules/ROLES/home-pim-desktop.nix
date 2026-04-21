{
inputs,
...
}:
{
  flake.modules.homeManager.role-pim-desktop = {config, lib, ...}: {

    #homeWith.desktop.enable = true;
    programs.tmux.shortcut = "a";

    imports = with inputs.self.modules.homeManager; [

      pim-obs
      pim-alacritty
      pim-aoe
      pim-monitoring
      pim-kitty
      pim-ghostty
      pim-firefox
      pim-librewolf
      pim-wrofi
      pim-gimp
      pim-myhotkeys
      pim-thunderbird
      pim-freedesktop
      pim-hyprland
      pim-hypr-longpress
      pim-fonts

    ];

  };
}
