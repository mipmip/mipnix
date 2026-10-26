{ inputs, ... }:
{
  flake.modules.nixos.stinkie = { config, pkgs, ... }:
  let
    # immich 3.1.0, taken from the flake's already-locked `unstable` input.
    #
    # The pinned channel (26.05) ships 2.7.5, which upstream has declared end of
    # life and nixpkgs now marks insecure (CVE-2026-59258, CVE-2026-82272), so
    # it refuses to evaluate and blocks every rebuild of this host.
    #
    # Only the package comes from unstable. The NixOS module stays on the pinned
    # channel: the two differ by six lines (a doc change on `host`, and a dropped
    # MPLCONFIGDIR workaround) and their option sets are identical. postgresql
    # and vectorchord also stay pinned, and vectorchord is 1.1.1 on both
    # channels, which is what the database already runs, so no extension
    # migration is involved.
    #
    # immich migrates its own schema on first start. That is one-way: rolling the
    # system closure back to 2.7.5 would leave a database it cannot read, so
    # deploy-rs magic rollback does not cover it. Take a pg_dumpall first.
    unstablePkgs = import inputs.unstable {
      inherit (pkgs.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  in {

    services.immich = {
      enable = true;
      package = unstablePkgs.immich;

      # Media lives on the LUKS disk, never on a network share. The directory
      # has to exist with the right owner before the service starts, because the
      # module only creates its default location; see systemd.tmpfiles below.
      mediaLocation = "/mnt/immich-data/immich";

      # Reachable from the LAN and from nebula nodes. The module defaults to
      # localhost, which would make it unreachable from anything. stinkie sets
      # networking.firewall.enable = false, so openFirewall is moot, and the
      # host is not exposed beyond the LAN and the mesh.
      host = "0.0.0.0";
      port = 2283;

      # CPU only. This nixpkgs builds onnxruntime without CUDA, so the worker
      # has no CUDA execution provider and the device nodes below do nothing for
      # it. They are passed through for NVENC video transcoding, which is a
      # separate path. Revisit when the RTX 3060 lands.
      machine-learning.enable = true;
      accelerationDevices = [
        "/dev/nvidia0"
        "/dev/nvidiactl"
        "/dev/nvidia-uvm"
        "/dev/nvidia-uvm-tools"
      ];

      # database.enable and redis.enable default to true. Postgres is reached
      # over /run/postgresql with peer authentication, so there is no password
      # and nothing to put in agenix.
    };

    # The external library: the aperture-originals tree copied from piethein,
    # which immich indexes in place and never writes to. Kept outside
    # mediaLocation so immich's own managed tree and the read-only originals
    # stay separable, and so the copy remains comparable with the NAS source.
    systemd.tmpfiles.rules = [
      "d /mnt/immich-data/immich 0750 ${config.services.immich.user} ${config.services.immich.group} -"
      "d /mnt/immich-data/aperture-originals 0750 ${config.services.immich.user} ${config.services.immich.group} -"
    ];

  };
}
