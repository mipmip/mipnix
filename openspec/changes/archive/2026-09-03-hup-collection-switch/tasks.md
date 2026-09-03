## 1. Bump huphop input

- [x] 1.1 huphop input already at v1.4.0 (locked rev `012931f` = "Release v1.4.0");
      `nix flake update huphop` was a no-op. Source confirmed to have `switchData.Collection`
      populated from `m.selColl` in `renderSwitchCommand` (internal/tui/multiplex.go)
- [x] 1.2 Input provides ≥ 1.4 (verified via source/tag). Note: running system still reports
      `hup 1.3.0` until the next rebuild brings the locked v1.4.0

## 2. Wrapper + config

- [x] 2.1 `hup-tmux-switch` now takes `<session> <repo> <target>` ($1 = resolved session name),
      keeping the `tr ':.'` sanitize on session and window names
- [x] 2.2 `switch_command` session name is
      `{{if .Collection}}{{.Collection}}{{else}}{{.Short}}->{{.OwnerLower}}{{end}}`, then
      `{{.Repo}}` and `{{.Target}}`

## 3. Verification

- [x] 3.1 `nix-instantiate --parse` OK; built the generated `huphop/config.yaml` and confirmed the
      rendered `switch_command`; `bash -n` on the generated wrapper OK; wrapper signature confirmed
      `session="$1"; repo="$2"; target="$3"`
- [ ] 3.2 Post-switch: `hup config check` reports the config valid (NEEDS REBUILD)
- [ ] 3.3 Post-switch: switching a repo from the flat view lands in a `<short>-><owner>` session
      (unchanged behavior) (NEEDS REBUILD)
- [ ] 3.4 Post-switch: switching a repo from within a collection lands in a session named after the
      collection, one window per repo (NEEDS REBUILD + a defined collection)
- [ ] 3.5 A collection name containing a `.` still switches without a tmux target error (NEEDS REBUILD)
