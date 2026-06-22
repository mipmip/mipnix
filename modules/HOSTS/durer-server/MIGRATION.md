# Umami migration: AWS → durer (as-is)

Move the umami analytics app + its PostgreSQL database off two AWS EC2 hosts
(account 104144963194, eu-central-1) onto **durer** (Hetzner Cloud VPS,
Nebula 192.168.100.12). This is an **as-is** migration: the DB schema-migration
path is known-broken, so we move the data verbatim into the **same PostgreSQL
major version (14)** and run the **same container image** — nothing upgrades.

## Source of truth (verified 2026-06-19)

| | Where | What |
|---|---|---|
| App | `dockers1` i-0a8da24472db7eb77, t3.small, public `3.122.235.238` = `umami.pimsnel.com` | NixOS `oci-container`, image `ghcr.io/umami-software/umami:postgresql-v2.5.0`, port `3002→3000`. **Stateless** (0 volumes/mounts). SSH `root@umami.pimsnel.com -i ~/.ssh/TxN/nixos-ec2nix-server`. |
| DB | `db` i-0e4965d3c01897842, t3.micro, private `10.0.1.39` | **PostgreSQL 14**, port 5432, DB `umami`, role `umami`. Data `/data/postgresql` = **9.5 GB on disk** (dedicated 20 GB EBS). Reachable via **SSM** only (private). |
| App→DB | env on dockers1 | `DATABASE_URL=postgresql://umami:umami@10.0.1.39:5432/umami` |

**`HASH_SALT`** (env on dockers1) keys umami's sessions/data and **must be reused
exactly** on durer, or logins/data break. We capture it without ever printing it
(Phase 1.3).

## Target after migration

durer runs the **same umami container** plus a **dedicated PostgreSQL 14
container** (NOT durer's existing host PG17 — see below), both on a private docker
network, fronted by nginx/ACME on `umami.pimsnel.com`. The PG14 data lives on a
**dedicated Hetzner Volume mounted at `/data`** (mirrors AWS; chosen over a disk
rescale which needs poweroff + is irreversible).

> **Why a separate PG14, not durer's existing Postgres:** durer ALREADY runs
> **PostgreSQL 17** (host service on 127.0.0.1:5432, serving Matrix/webshop).
> umami v2.5.0 targets **PG14** and its DB migrations are known-broken, so loading
> a PG14 dump into PG17 is NOT an as-is move (cross-version restore risk) and would
> couple umami's fate to Matrix/webshop. We keep umami's DB in its own PG14
> container — isolated, true as-is, trivially removable.

---

## Phase 0 — Hetzner Volume (you, console; no downtime)

1. Hetzner Cloud console → **Volumes → Create Volume**, attach to durer.
   - Size **20 GB**, location = durer's location.
   - **"Do not automatically mount / format"** (NixOS owns `/etc/fstab`; Hetzner's
     automount would be clobbered on rebuild).
2. It hot-attaches as a new block device. Find it:
   ```sh
   ssh -i ~/.ssh/id_ed25519 pim@192.168.100.12 'lsblk -o NAME,SIZE,TYPE,SERIAL,WWN'
   ```
   The new disk (no partitions, ~20G) is e.g. `/dev/sdb`. Hetzner volumes also
   appear at a stable path `/dev/disk/by-id/scsi-0HC_Volume_<id>` — prefer that.
3. Format + label `umami-data` (ext4):
   ```sh
   ssh -i ~/.ssh/id_ed25519 pim@192.168.100.12 \
     'sudo mkfs.ext4 -L umami-data /dev/disk/by-id/scsi-0HC_Volume_<id>'
   ```
   (Confirm the device is the empty new volume first — do NOT format `/dev/sda*`.)

---

## Phase 1 — Declarative durer config (in ~/mipnix)

### 1.1  hardware.nix — mount the volume at /data
Add to `flake.modules.nixos.durer` in `hardware.nix`:
```nix
fileSystems."/data" = {
  device = "/dev/disk/by-label/umami-data";
  fsType = "ext4";
};
```

### 1.2  configuration.nix — docker + PG14 container + umami container + nginx
Add inside `flake.modules.nixos.durer`. Both containers sit on a private docker
network `umami-net`, so umami reaches the DB by container name `umami-db` — it
never touches durer's host PG17.
```nix
# Docker for the as-is umami stack (durer's host has none yet)
virtualisation.docker.enable = true;

# Dedicated, isolated PostgreSQL 14 for umami (NOT the host PG17)
age.secrets."umami-env".file = ../../../secrets/umami-env.age;
virtualisation.oci-containers.containers = {
  umami-db = {
    image = "postgres:14-alpine";
    environmentFiles = [ config.age.secrets."umami-env".path ];  # POSTGRES_* live here
    volumes = [ "/data/postgresql:/var/lib/postgresql/data" ];   # on the Hetzner volume
    extraOptions = [ "--network=umami-net" ];
  };
  umami = {
    image = "ghcr.io/umami-software/umami:postgresql-v2.5.0";
    environmentFiles = [ config.age.secrets."umami-env".path ];  # DATABASE_URL + HASH_SALT
    dependsOn = [ "umami-db" ];
    ports = [ "127.0.0.1:3002:3000" ];
    extraOptions = [ "--network=umami-net" ];
  };
};

# Create the private docker network before the containers start
systemd.services.init-umami-net = {
  description = "create umami-net docker network";
  after = [ "docker.service" ]; requires = [ "docker.service" ];
  wantedBy = [ "docker-umami-db.service" "docker-umami.service" ];
  serviceConfig.Type = "oneshot";
  script = ''
    ${pkgs.docker}/bin/docker network inspect umami-net >/dev/null 2>&1 \
      || ${pkgs.docker}/bin/docker network create umami-net
  '';
};

# nginx vhost
services.nginx.virtualHosts."umami.pimsnel.com" = {
  enableACME = true;
  forceSSL = true;
  locations."/".proxyPass = "http://127.0.0.1:3002";
};
```
Notes:
- `DATABASE_URL=postgresql://umami:<pw>@umami-db:5432/umami` — host is the container
  name `umami-db`, resolved on `umami-net`. Nothing binds 5432 on the host, so it's
  off the public interface and away from PG17.
- The PG14 container initializes the DB from `POSTGRES_USER`/`POSTGRES_PASSWORD`/
  `POSTGRES_DB` (set them = `umami` in the env file). On first boot it creates an
  empty `umami` DB; Phase 2 replaces it with the AWS data.

### 1.3  Capture HASH_SALT + build the umami-env secret (never printed)
On the laptop, pull the salt straight into a local env file, add the rest, then
encrypt — the value is piped, never echoed to the terminal:
```sh
cd ~/mipnix
umask 077
# One env file shared by both containers: POSTGRES_* (consumed by umami-db),
# DATABASE_URL + HASH_SALT + flags (consumed by umami). Pick a DB password.
{
  printf 'POSTGRES_USER=umami\nPOSTGRES_PASSWORD=%s\nPOSTGRES_DB=umami\n' "$DBPW"
  printf 'DATABASE_TYPE=postgresql\n'
  printf 'DATABASE_URL=postgresql://umami:%s@umami-db:5432/umami\n' "$DBPW"
  printf 'DISABLE_TELEMETRY=1\nDISABLE_UPDATES=1\n'
  # HASH_SALT pulled from the running AWS container, appended without display:
  ssh -i ~/.ssh/TxN/nixos-ec2nix-server root@umami.pimsnel.com \
    'docker inspect umami --format "{{range .Config.Env}}{{println .}}{{end}}"' \
    | grep '^HASH_SALT='
} > /tmp/umami-env
# (set DBPW first in your shell, e.g.  set -x DBPW (openssl rand -hex 16)  — never commit it)
# add recipients to secrets/secrets.nix:  "umami-env.age".publicKeys = [ pim durer ];
( cd secrets && EDITOR='cp /tmp/umami-env' agenix -e umami-env.age -i ~/.ssh/id_ed25519 )
shred -u /tmp/umami-env
```
Then add to `secrets/secrets.nix`:
```nix
"umami-env.age".publicKeys = [ pim durer ];
```

### 1.4  Deploy durer with an EMPTY db first (validate wiring)
```sh
cd ~/mipnix
nix flake check
nix run github:serokell/deploy-rs -- .#durer    # or your deploy alias
```
Verify on durer: Postgres 14 up on /data, umami container healthy, nginx serving
`umami.pimsnel.com` (will show empty/fresh umami until Phase 2). Don't flip DNS yet.

---

## Phase 2 — Data transfer (brief umami downtime)

1. **Freeze writes** — stop the AWS umami app so the dump is consistent:
   ```sh
   ssh -i ~/.ssh/TxN/nixos-ec2nix-server root@umami.pimsnel.com 'docker stop umami'
   ```
2. **Dump on the AWS db host via SSM** (it's private). Run pg_dump as the postgres
   user into /data (has room), custom format:
   ```sh
   CMD=$(aws ssm send-command --region eu-central-1 \
     --instance-ids i-0e4965d3c01897842 \
     --document-name AWS-RunShellScript \
     --parameters 'commands=["sudo -u postgres pg_dump -Fc -d umami -f /data/umami.dump","ls -lh /data/umami.dump"]' \
     --query Command.CommandId --output text)
   # poll get-command-invocation until Success
   ```
   `-Fc` = compressed custom format → expect well under the 9.5 GB on-disk size.
3. **Pull the dump out.** The db host has no public IP; options:
   - Easiest: copy it to dockers1 (public) over the VPC, then scp to the laptop,
     then to durer over Nebula; **or**
   - SSM port-forward a session and `scp` directly. Pick whichever your access
     allows — the dump just needs to land on durer at `/data/umami.dump`.
4. **Restore into the PG14 container** (drop + recreate for a clean, migration-free
   load). The dump is on durer at `/data/umami.dump`; restore *inside* the
   `umami-db` container so it uses that container's PG14 tools:
   ```sh
   ssh -i ~/.ssh/id_ed25519 pim@192.168.100.12 '
     sudo systemctl stop docker-umami.service                      # stop the app, keep DB up
     sudo cp /data/umami.dump /data/postgresql/umami.dump          # visible inside the DB container
     sudo docker exec -i umami-db dropdb -U umami umami
     sudo docker exec -i umami-db createdb -U umami -O umami umami
     sudo docker exec -i umami-db pg_restore -U umami --no-owner --role=umami \
        -d umami /var/lib/postgresql/data/umami.dump
     sudo rm /data/postgresql/umami.dump
     sudo systemctl start docker-umami.service'
   ```
   Same major version (14→14) ⇒ **no schema migration runs**. This is the as-is win.
5. **Smoke test** (still via Nebula, before DNS): log in (HASH_SALT matched →
   existing account works), historical dashboards render, send a test pageview and
   confirm it lands.

---

## Phase 3 — Cutover (you + me)

1. Final pre-flip check over Nebula / a temporary hosts entry.
2. Repoint **`umami.pimsnel.com`** DNS → durer's public IP. ACME issues on first hit.
3. Watch 24–48 h: events flow, no 5xx, no Postgres errors (`journalctl -u postgresql`).
4. Update any tracking snippets only if the hostname changed (it doesn't — kept).

---

## Phase 4 — Decommission AWS (after confidence window)

1. **Stop, don't delete** `dockers1` + `db` for a few days (rollback insurance).
2. Confirm nothing else uses the public subnet/NAT (possible extra ~$10/mo saving
   if the NAT + its Elastic IP existed only for dockers1).
3. Terminate `dockers1` + `db`, delete their EBS volumes (10G+10G+20G), release the
   public IPv4 on dockers1.

## Rollback

Any time before Phase 4: restart the AWS umami container
(`docker start umami` on dockers1) and point DNS back. durer's stack can stay up in
parallel; nothing on the AWS side is destroyed until Phase 4.

## Cost delta (2026-06)

- Save: AWS umami stack ≈ **$30/mo + 21% VAT ≈ $36/mo** (account has no RIs/Savings
  Plans; all on-demand list price).
- Add: Hetzner 20 GB Volume ≈ **€0.88/mo (~$1)**; durer base price unchanged.
- **Net ≈ $35/mo (~$420/yr)** saved; more if NAT/EIP also drop.
