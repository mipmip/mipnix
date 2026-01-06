{ lib, ... }:

{
  options.nixos.ai = {
    enable = lib.mkEnableOption "Enable ai";
  };

  options.nixos.aiLocal = {
    enable = lib.mkEnableOption "Enable localAi";
  };

  options.nixos.vibecoding = {
    enable = lib.mkEnableOption "Enable Vibe Coding";
  };

  options.nixos.litellm = {
    enable = lib.mkEnableOption "Enable LiteLLM";
  };

}

