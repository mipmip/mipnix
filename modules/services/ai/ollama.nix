{ inputs, ... } : {
  flake.modules.nixos.ai-ollama = { pkgs, ... }: {

    environment.systemPackages = with pkgs; [
      pkgs.unstable.ollama
      pkgs.unstable.llama-cpp
    ];

  };
}



