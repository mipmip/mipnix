# Tasks

Schema source: https://github.com/speclib/openspec-tinychange-schema

## 1. Implementation

- [x] 1.1 Register `"honeybadger-conf.age".publicKeys = [ pim cichorei doornappel peterspav ];` in `secrets/secrets.nix`
- [x] 1.2 Encrypt `/tmp/honey.txt` into `secrets/honeybadger-conf.age` with agenix, using the identity helper from `RUNME.d/00-helpers.sh`
- [x] 1.3 Add `modules/USERS/pim/honeybadger-secret.nix` exposing `flake.modules.nixos.secrets-honeybadger`, with `age.secrets.honeybadger-conf = { file = ../../../secrets/honeybadger-conf.age; path = "/home/pim/.honeybadger.conf"; symlink = false; owner = "pim"; group = "users"; mode = "600"; }`
- [x] 1.4 Import `secrets-honeybadger` in the NixOS module of `cichorei-laptop`, `doornappel-laptop` and `peterspav-laptop`
- [ ] 1.5 Shred `/tmp/honey.txt` once the encrypted file exists (left to Pim: deleting the plaintext is irreversible and the decrypt roundtrip needs the SSH passphrase)

## 2. Verification

- [x] 2.1 `nix eval` of `system.build.toplevel.drvPath` succeeds for cichorei, doornappel and peterspav; `age.secrets.honeybadger-conf` resolves to path `/home/pim/.honeybadger.conf`, owner `pim`, group `users`, mode `600`, `symlink = false` on all three, and is absent on hurry, harry, dapperehaan, lavendel, zonnehoed and durer
- [ ] 2.2 After `nixos-rebuild switch`, confirm `stat -c '%U %G %a' ~/.honeybadger.conf` reports `pim users 600` and the file is not a symlink
- [x] 2.3 The four recipient stanzas in `secrets/honeybadger-conf.age` match the tags produced by encrypting to `pim`, `cichorei`, `doornappel` and `peterspav` individually. `./RUNME.sh rekey` is not run here because it prompts for the SSH passphrase
