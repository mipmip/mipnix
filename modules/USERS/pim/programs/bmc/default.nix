{
inputs,
...
}:
{
  #      "totp_script": "rbw code \"AWS TechNative\"",
  #    "profile_scripts": {
  #      "wa-snel-wasnel-main": "rbw code \"AWS SNEL mipmip\""
  #    },

  flake.modules.homeManager.pim-bmc = {
    home.file = {
      ".config/bmc" = {
        source = ./bmc;
        recursive = true;
      };
    };
  };
}
