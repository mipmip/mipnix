## 1. Shared Helper

- [x] 1.1 Add `with_age_identity` function to RUNME.sh that creates a temp file via `mktemp`, runs `nix shell nixpkgs#ssh-to-age -c ssh-to-age -private-key -i ~/.ssh/id_ed25519 -o $tmpfile`, exports `AGE_IDENTITY=$tmpfile`, and sets `trap "shred -u $tmpfile" RETURN`
- [x] 1.2 Add error handling: if `ssh-to-age` fails, clean up and exit

## 2. Rekey Command

- [x] 2.1 Add `rekey` command to RUNME.sh with `make_command` registration
- [x] 2.2 Implement `rekey` function that calls `with_age_identity` and runs `agenix --rekey -i $AGE_IDENTITY`

## 3. Refactor new_nebula_node

- [x] 3.1 Wrap `new_nebula_node` body to use `with_age_identity`
- [x] 3.2 Replace all `age --decrypt -i ~/.ssh/id_ed25519` calls with `age --decrypt -i $AGE_IDENTITY`
