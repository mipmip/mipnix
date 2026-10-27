{ inputs, ... }:
let
  # Single definition of this host's restic datasets; consumed both by the
  # backup role below and (as bare repo names) by the aggregated
  # `flake.resticRepos`. A function because the DB-dump command needs
  # `pkgs`/`config`; `builtins.attrNames` never forces those values, so the
  # registry calls it with empty args. Same shape as durer.
  #
  # Two datasets, split by how they are produced rather than by what they cost.
  #
  # The database is the irreplaceable half. It holds the face clusters and the
  # search embeddings, which represent a full machine-learning pass over 29177
  # files and exist nowhere else. The photos themselves are replaceable: the
  # originals are still on piethein under Archief/fotos/aperture-originals.
  #
  # The media is backed up anyway, on purpose. A restic repository on the NAS is
  # a separate copy rather than a reference to those originals, so this does
  # duplicate roughly 92 GB. The gain is one rule with no reasoning about which
  # files happen to be safe already, and no gap for a phone upload to fall
  # through. piethein has the room.
  datasetsFor = { pkgs, config }: {
    # pg_dumpall rather than a live copy: a file-level backup of a running
    # postgres is not restorable. Upstream immich recommends dumpall, and it is
    # what was verified by hand before the 2.7.5 to 3.1.0 migration.
    stinkie-immich-db = {
      paths = [ "/var/backups/restic/immich.sql" ];
      keep = [
        "--keep-hourly" "24" "--keep-daily" "7" "--keep-weekly" "5"
        "--keep-monthly" "12" "--keep-yearly" "9999"
      ];
      prepareCommand = ''
        install -d -m 0700 /var/backups/restic
        ${pkgs.util-linux}/bin/runuser -u postgres -- \
          ${config.services.postgresql.package}/bin/pg_dumpall --clean --if-exists \
          > /var/backups/restic/immich.sql
      '';
      cleanupCommand = "rm -f /var/backups/restic/immich.sql";
    };

    # Named explicitly rather than backing up the whole /mnt/immich-data mount,
    # because the mount also holds cathalijne-archief: 295 GB synced from
    # piethein for a second immich user. Those originals already live on the NAS
    # under /volume1/CathalijneArchief, nothing uploads into that tree, and
    # including it would roughly quadruple this repo to re-store files the NAS
    # already has. The backup role has no exclude option, so the exclusion is
    # expressed by listing what to include.
    #
    # Anything added under /mnt/immich-data later is therefore NOT backed up
    # until it is named here.
    stinkie-immich-media = {
      paths = [
        "/mnt/immich-data/immich"             # managed: thumbs, transcodes, uploads
        "/mnt/immich-data/aperture-originals" # pim's photos
      ];
      keep = [
        "--keep-hourly" "24" "--keep-daily" "7" "--keep-weekly" "5"
        "--keep-monthly" "12" "--keep-yearly" "9999"
      ];
    };
  };
in
{
  flake.resticRepos.stinkie = builtins.attrNames (datasetsFor { pkgs = { }; config = { }; });

  flake.modules.nixos.stinkie = { config, pkgs, ... }: {

    imports = with inputs.self.modules.nixos; [
      backup-restic-piethein
    ];

    # Direct over the LAN (192.168.2.19 to 192.168.2.100), so no relay, as on
    # dapperehaan. The first media run moves about 92 GB and will take a while
    # over wifi; subsequent runs are incremental.
    mipnix.backup.piethein = {
      enable = true;
      datasets = datasetsFor { inherit pkgs config; };
    };

  };
}
