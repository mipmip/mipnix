{ inputs, ... } : {
  flake.modules.nixos.ai-openwebui = { pkgs, ... }: {
    services.open-webui = {
      enable = true;
      package = pkgs.unstable.open-webui;
      host = "0.0.0.0";
    };
  };
}
