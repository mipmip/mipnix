{ inputs, ... }:
{
  # The Work pool: /home/pim/Work kept identical across every member, carried
  # over the nebula mesh. A host joins by setting `mipnix.syncthing.pool.enable`
  # and contributing its device ID to `flake.syncthingDevices` (see
  # syncthing-devices-option.nix). Exactly one member sets `hub = true`.
  #
  # Peers are DERIVED: the registry minus this host's own name. Nothing here
  # reads another host's evaluated configuration, because doing so would make
  # every member evaluate every other member, which is a cycle as soon as two
  # members exist. The registry carries plain strings for exactly this reason.
  #
  # Mesh-only by construction. Global and local discovery and relaying are all
  # off, and peers are addressed as tcp://<hostname>:22000. The name resolves
  # because networking-nebula writes every node into networking.extraHosts from
  # flake.nebulaNodes, so a node's IP is still stated in exactly one place in the
  # repo. Mesh membership is therefore a prerequisite for pool membership, not
  # something this module works around.
  flake.modules.nixos.syncthing-work-pool =
    { config, lib, ... }:
    let
      cfg = config.mipnix.syncthing.pool;
      host = config.networking.hostName;

      registry = inputs.self.syncthingDevices;
      peers = lib.filterAttrs (name: _: name != host) registry;

      folderId = "pim-work";
      folderPath = "/home/pim/Work";

      # Build output and dependency trees never enter the pool. Without this a
      # Work folder syncs node_modules across three machines and then keeps it in
      # restic for a year. overrideFolders below is true, so a pattern added in
      # the web UI is reverted on restart; the list lives here and nowhere else.
      ignore = [
        "(?d).DS_Store"
        "node_modules"
        ".venv"
        "__pycache__"
        "target"
        ".direnv"
        "result"
        "result-*"
        ".stversions"
      ];
    in
    {
      options.mipnix.syncthing.pool = {
        enable = lib.mkEnableOption "membership of the /home/pim/Work syncthing pool";
        hub = lib.mkEnableOption ''
          hold the authoritative copy of the pool folder. The hub takes the
          folder receive-only so nothing edited on it propagates outward, and
          versions incoming changes so a deletion arriving from another member
          is retained rather than erased everywhere at once. Set on exactly one
          member; the host that is the hub is also the host that backs the
          folder up
        '';
      };

      config = lib.mkIf cfg.enable {

        # A member that is not in the registry would come up with a
        # self-generated identity that no peer recognises, and would look like a
        # working member while syncing with nobody. Fail the build instead.
        assertions = [
          {
            assertion = registry ? ${host};
            message = ''
              ${host} enables mipnix.syncthing.pool but has no entry in
              flake.syncthingDevices. Generate its identity, commit it to
              secrets/syncthing-${host}.{crt,key}.age, and add
              flake.syncthingDevices.${host} in this host's own file.
            '';
          }
        ];

        # Decrypted as root; the syncthing unit's ExecStartPre carries the "+"
        # prefix, so it copies these into the config dir as root before dropping
        # to the service user. No owner override needed here.
        age.secrets = {
          "syncthing-${host}-cert".file = ../../../secrets + "/syncthing-${host}.crt.age";
          "syncthing-${host}-key".file = ../../../secrets + "/syncthing-${host}.key.age";
        };

        services.syncthing = {
          enable = true;

          # pim's own home, not the module's /var/lib/syncthing default: the
          # folder has to be where pim actually works. configDir follows dataDir
          # to /home/pim/.config/syncthing.
          user = "pim";
          group = "users";
          dataDir = "/home/pim";

          # The identity is supplied, never self-generated, so a rebuilt host is
          # a pool member on first boot with no step performed on the host.
          cert = config.age.secrets."syncthing-${host}-cert".path;
          key = config.age.secrets."syncthing-${host}-key".path;

          # The repository is the configuration. Anything added through the web
          # UI is reverted on restart, which is intended.
          overrideDevices = true;
          overrideFolders = true;

          # Loopback only. Exposing the GUI on the mesh is a separate decision.
          guiAddress = "127.0.0.1:8384";

          settings = {
            options = {
              # Nothing outside the mesh learns a device ID or an address.
              globalAnnounceEnabled = false;
              localAnnounceEnabled = false;
              relaysEnabled = false;
              natEnabled = false;
              urAccepted = -1;
              # Explicit, so the default does not quietly add QUIC and a relay
              # endpoint alongside the one transport this pool is meant to use.
              listenAddresses = [ "tcp://0.0.0.0:22000" ];
            };

            devices = lib.mapAttrs (name: id: {
              inherit id;
              addresses = [ "tcp://${name}:22000" ];
            }) peers;

            folders.${folderId} = {
              path = folderPath;
              label = "Work";
              devices = lib.attrNames peers;
              ignorePatterns = ignore;

              # receiveonly stops edits made ON the hub from propagating. It says
              # nothing about deletions arriving FROM a member: versioning is
              # what covers those. Both are set, for different reasons.
              type = if cfg.hub then "receiveonly" else "sendreceive";
            }
            // lib.optionalAttrs cfg.hub {
              # Staggered rather than trashcan: several machines write here, so
              # thinning old versions on a schedule fits better than keeping
              # exactly one copy of each deleted file. Keeps a year.
              versioning = {
                type = "staggered";
                params = {
                  cleanInterval = "3600";
                  maxAge = "31536000";
                };
              };
            };
          };
        };
      };
    };
}
