{ inputs, ... }:
{
  flake.modules.nixos.dapperehaan = { config, pkgs, ... }:
  {
    imports = [ inputs.startaste.nixosModules.startaste ];

    # Bring the startaste package into pkgs for the module's default package.
    nixpkgs.overlays = [ inputs.startaste.overlays.default ];

    # Source credentials for the sync timer, and the hashed bearer-token records
    # for the MCP endpoint. Both are PATHS into agenix, never values: a literal
    # in a Nix option would land in the world-readable store. Owned by the
    # service user the module creates.
    age.secrets."startaste-env" = {
      file = ../../../secrets/startaste-env.age;
      owner = "startaste";
      group = "startaste";
      mode = "400";
    };
    age.secrets."startaste-mcp-tokens" = {
      file = ../../../secrets/startaste-mcp-tokens.age;
      owner = "startaste";
      group = "startaste";
      mode = "400";
    };

    services.startaste = {
      enable = true;

      # `user` stays at its default: the module only creates the startaste system
      # user while it is unset, and agenix needs that user to exist at activation
      # to chown the secrets above. linny-mcp relies on the same mechanism here.

      # HN has no API — startaste scrapes with the account login — so this file
      # holds a real password, not just the scopeless GITHUB_TOKEN. The module's
      # units are hardened with ProtectHome, which is also why the application's
      # own .env discovery cannot be used: .env resolves from the working
      # directory and would be unreachable.
      environmentFile = config.age.secrets."startaste-env".path;

      # Periodic refresh. systemd owns the schedule; the app has no interval loop.
      # Interval left at the module's 1h default — stars and upvotes move slowly,
      # and an overlapping tick is skipped rather than run concurrently.
      sync.enable = true;

      # MCP for Claude Online/Mobile. Bound to the nebula mesh IP so it is
      # reachable only over the overlay; TLS terminates upstream on durer (see
      # ../durer-server/taste.nix). 8766 is the module default and does not
      # collide with linny-mcp on 8765.
      #
      # NOTE the server opens the database read-only and refuses to create one,
      # so on a host that has never synced it exits and retries (the module sets
      # Restart=always with no start limit) until the first sync lands. Expect
      # taste.pimsnel.com to 502 for the first few minutes after a fresh deploy.
      mcp = {
        enable = true;
        listenAddress = "192.168.100.2";
        port = 8766;
        tokensFile = config.age.secrets."startaste-mcp-tokens".path;
        # The MCP transport checks the Host header against an allow-list to
        # defend against DNS rebinding. durer forwards the public name, which is
        # not loopback and not the bind address, so it must be declared or every
        # proxied request is refused with 421. Loopback and 192.168.100.2:8766
        # are accepted without declaring them.
        publicHostname = "taste.pimsnel.com";
      };

      # The dashboard has NO authentication of any kind, so it is bound to the
      # mesh and deliberately NOT fronted by any vhost on durer. Any node on the
      # overlay can read the collection; that is the accepted trade.
      dashboard = {
        enable = true;
        listenAddress = "192.168.100.2";
        port = 8421;
      };
    };
  };
}
