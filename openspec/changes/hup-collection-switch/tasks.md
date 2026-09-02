## 1. Bump huphop input

- [ ] 1.1 Update the `huphop` flake input to a 1.4 rev/tag that includes `Collection` in the
      `switch_command` template context; `nix flake lock --update-input huphop`
- [ ] 1.2 Confirm the resolved `hup --version` is ≥ 1.4

## 2. Wrapper + config

- [ ] 2.1 In `modules/USERS/pim/programs/huphop/default.nix`, change `hup-tmux-switch` to take the
      resolved session name as `$1` (drop the internal `short->owner` build), keeping `<repo>`
      `<target>` and the `tr ':.'` sanitize on session and window names
- [ ] 2.2 Update `hupConfig.modes.multiplex.switch_command` to pass session name
      `{{if .Collection}}{{.Collection}}{{else}}{{.Short}}->{{.OwnerLower}}{{end}}`, then
      `{{.Repo}}` and `{{.Target}}`

## 3. Verification

- [ ] 3.1 `nix-instantiate --parse` on the changed module; `bash -n` on the generated wrapper
- [ ] 3.2 Post-switch: `hup config check` reports the config valid
- [ ] 3.3 Post-switch: switching a repo from the flat view lands in a `<short>-><owner>` session
      (unchanged behavior)
- [ ] 3.4 Post-switch: switching a repo from within a collection lands in a session named after the
      collection, one window per repo
- [ ] 3.5 A collection name containing a `.` still switches without a tmux target error
