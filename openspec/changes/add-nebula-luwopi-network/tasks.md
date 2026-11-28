# Tasks

## 1. Secrets and identities

- [x] 1.1 Add `nebula-luwopi-ca.crt.age`,
  `nebula-luwopi-delliebellie.{crt,key}.age` and
  `nebula-luwopi-peterspav.{crt,key}.age` to `secrets/secrets.nix`, each with
  recipients `[ pim delliebellie peterspav ]`. Verify with
  `grep nebula-luwopi secrets/secrets.nix`.
- [x] 1.2 Encrypt `/tmp/tmpnebula-pim/ca.crt` and the delliebellie
  `post.crt`/`post.key` into the three delliebellie secret files with the same
  recipients. Verify by decrypting each file and running
  `nebula-cert print` on the certificate, which must report name `post` and
  network `192.168.200.10/24`.
- [ ] 1.3 Request a certificate for peterspav from the LUWOPI group
  administrator, then encrypt it as `nebula-luwopi-peterspav.{crt,key}.age`
  with recipients `[ pim delliebellie peterspav ]`. Verify with
  `nebula-cert print` that the certificate name and address differ from
  delliebellie's.
- [x] 1.4 Shred `/tmp/tmpnebula-pim/` and abandon the kept jj commit
  `b660090` in `/home/pim/gh.luwopi/arcana-one`. Verify that
  `git for-each-ref --contains b660090` produces no output and that
  `post.key` no longer exists outside `secrets/*.age`.

## 2. The `nebula-luwopi` includable

- [x] 2.1 Create `modules/services/networking/nebula-luwopi.nix` exposing
  `flake.modules.nixos.nebula-luwopi` with
  `mipnix.nebula.luwopi.enable` and the `luwopi` network: group CA,
  host-derived certificate and key, lighthouse `192.168.200.1`, static host
  map `192.168.200.1 -> 54.93.81.45:4242`, `isLighthouse = false`, outbound
  `any/any` and empty inbound. Verify with
  `nix eval .#nixosConfigurations.delliebellie.config.services.nebula.networks.luwopi --apply builtins.attrNames`.
- [x] 2.2 Set the agenix secrets' owner and group to `nebula-luwopi` and mode
  `600`. Verify with `nix eval` that each secret path resolves under
  `/var/lib/nebula/`.
- [x] 2.3 Record the external CA, the certificate expiry date `2027-09-10`
  and the group administrator as the renewal owner in a comment in the module.
  Verify by reading the file.

## 3. Host membership

- [x] 3.1 Import the includable in
  `modules/HOSTS/delliebellie-laptop/configuration.nix` and set
  `mipnix.nebula.luwopi.enable = true`. Verify with
  `nix eval .#nixosConfigurations.delliebellie.config.services.nebula.networks.luwopi.enable`,
  which must return `true`.
- [ ] 3.2 Import the includable in
  `modules/HOSTS/peterspav-laptop/configuration.nix` and set
  `mipnix.nebula.luwopi.enable = true`. Verify with
  `nix eval .#nixosConfigurations.peterspav.config.services.nebula.networks.luwopi.enable`,
  which must return `true`.
- [x] 3.3 Confirm both hosts still evaluate with the mesh unchanged: run
  `nix eval` on `services.nebula.networks.mesh.ca` before and after, and check
  the value is identical.

## 4. Rollout and verification

- [x] 4.1 Deploy delliebellie and verify the `nebula@luwopi` unit is active,
  `ip address show nebula.luwopi` reports `192.168.200.10/24`, and the log
  records a completed handshake with the lighthouse at `192.168.200.1` (the
  lighthouse does not answer ICMP, so ping is not a valid check).
- [ ] 4.2 From delliebellie, verify a group service is reachable:
  `curl -sS -o /dev/null -w '%{http_code}' http://192.168.200.2:8080` returns
  a response and `curl` to `http://192.168.200.2:11434` reaches ollama.
- [x] 4.3 Verify the member is not exposed: from arcana-one, a connection to
  `192.168.200.10` on port 22 must not connect, while delliebellie's
  connection to arcana-one still works.
- [x] 4.4 Verify the mipnix mesh is unaffected: `systemctl is-active
  nebula@mesh` is active and the syncthing Work pool still reports connected
  peers.
- [ ] 4.5 After peterspav's certificate is in place, deploy peterspav and
  repeat 4.1 and 4.2 from that host. Then confirm from arcana-one that both
  member addresses are distinct and reachable with different certificate
  names.
