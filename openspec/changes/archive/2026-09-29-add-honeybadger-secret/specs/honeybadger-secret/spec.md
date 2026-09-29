## ADDED Requirements

### Requirement: Honeybadger config stored as an agenix secret
The repository SHALL carry the Honeybadger configuration as `secrets/honeybadger-conf.age`, encrypted to the `pim` user key and to the host keys of pim's personal laptops: `cichorei`, `doornappel` and `peterspav`.

#### Scenario: Secret registered in secrets.nix
- **WHEN** `secrets/secrets.nix` is evaluated
- **THEN** `honeybadger-conf.age` SHALL have `publicKeys` containing `pim`, `cichorei`, `doornappel` and `peterspav`

#### Scenario: Rekey covers the new secret
- **WHEN** `./RUNME.sh rekey` runs
- **THEN** `secrets/honeybadger-conf.age` SHALL be re-encrypted along with every other age file, without an extra passphrase prompt

### Requirement: Dedicated module for the Honeybadger secret
The flake SHALL expose a NixOS module that declares the Honeybadger secret, separate from `system-trusted-pim`, so only hosts whose key can decrypt it import it.

#### Scenario: Module imported by the personal laptops
- **WHEN** the NixOS configurations of `cichorei`, `doornappel` and `peterspav` are evaluated
- **THEN** each SHALL import the Honeybadger secret module

#### Scenario: Other trusted-pim hosts unaffected
- **WHEN** a host such as `hurry`, `harry` or `dapperehaan` is evaluated
- **THEN** it SHALL NOT declare the Honeybadger secret, so its activation cannot fail on a decryption error

### Requirement: Honeybadger config placed in pim's home directory
On a host that imports the Honeybadger secret module, the decrypted configuration SHALL be present at `/home/pim/.honeybadger.conf` as a regular file owned by `pim:users` with mode `600`.

#### Scenario: Personal laptop activates the secret
- **WHEN** `cichorei`, `doornappel` or `peterspav` is rebuilt and activated
- **THEN** `/home/pim/.honeybadger.conf` SHALL contain the decrypted configuration, with owner `pim`, group `users` and mode `600`

#### Scenario: Reading the file without root
- **WHEN** pim opens `~/.honeybadger.conf`
- **THEN** the contents SHALL be readable without elevating privileges and without following a symlink into a root-only store path
