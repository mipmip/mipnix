{
inputs,
...
}:
{
  flake.modules.homeManager.pim-myhotkeys = { pkgs, ... }:
    let
      hk = inputs.self.lib.hotkeys;

      # myhotkeys is the desktop-wide sheet, so it takes every documented
      # entry, minus the neovim keymaps: 56 of them made the window taller
      # than the screen and buried every other section. They stay in keyb's
      # per-application sheet, which is where you are when you need them.
      keysJson = pkgs.writeText "myhotkeys-keys.json"
        (builtins.toJSON
          (hk.toMyhotkeys (hk.withoutTarget "nvim" inputs.self.hotkeys)));
    in
    {
      home.file = {
        "./.config/myhotkeys/keys.json".source = keysJson;
      };
    };
}
