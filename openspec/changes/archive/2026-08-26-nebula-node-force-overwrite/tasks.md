## 1. Overwrite helper and FORCE

- [x] 1.1 Add a `_confirm_overwrite "<what>"` helper to `RUNME.d/nebula.sh` that returns
      true when `$FORCE` is non-empty, otherwise runs `gum confirm "<what> already exists — overwrite?"`
- [x] 1.2 Document `FORCE` behaviour with a short comment near the top of `new_nebula_node`

## 2. Certificate overwrite prompt

- [x] 2.1 Replace the hard `exit 1` cert-existence guard with a `_confirm_overwrite`
      prompt; set a flag (e.g. `REGEN_CERTS`) from the result
- [x] 2.2 Make the IP/group/sign/encrypt block conditional on "certs absent OR overwrite
      confirmed"; when declined, print "keeping existing certificates" and continue
- [x] 2.3 Ensure the later secrets/wiring steps still run in the keep-existing path
      (they reference the on-disk `.age` files by name)

## 3. nebula.nix overwrite prompt

- [x] 3.1 In the wiring-file block, when `<host-dir>/nebula.nix` exists call
      `_confirm_overwrite`; on confirm regenerate it, on decline leave it unchanged and report

## 4. Machine-key overwrite prompt

- [x] 4.1 When a `<node>` let-binding exists, extract its current key value from the line
- [x] 4.2 If the existing key equals the machine's host key, skip silently (no prompt)
- [x] 4.3 If it differs, call `_confirm_overwrite`; on confirm replace only the quoted
      value on that line, on decline keep it
- [x] 4.4 Keep `systems` membership and `publicKeys` entries as add-if-absent (no prompt)

## 5. Verification

- [x] 5.1 `bash -n RUNME.d/nebula.sh` passes
- [x] 5.2 On a scratch copy: differing machine-key line is replaced (value only) and the
      result still parses with `nix-instantiate --parse`; identical key is left untouched
- [x] 5.3 With `FORCE=1`, simulate existing `nebula.nix` and confirm the helper reports
      overwrite without prompting; without `FORCE`, confirm `gum confirm` is invoked
- [x] 5.4 Confirm declining cert overwrite does not exit the function (control-flow review
      / traced dry-run of the guarded block)
