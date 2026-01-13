{ inputs, ... } : {
  flake.modules.nixos.vibecoding-utils = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [

      #unstable.aider-chat-full
      pkgs.unstable.aider-chat-with-bedrock

      aichat

      plandex
      plandex-server
      #      unstable.claude-code

      opencode
      goose
      #crush

      mods

    ];
  };
}

