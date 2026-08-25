## 1. Indexer service

- [ ] 1.1 In `modules/HOSTS/dapperehaan-server/linny-mcp.nix`, add `lindexer`/`idxJson` to the `let` (from `config.services.linny-mcp.package`)
- [ ] 1.2 Add `systemd.services.linny-mcp-index`: run as `linny-mcp`; `ExecStartPre` = `lindexer build -corpus … -index ${stateDir}/lindenIndex -state-dir ${stateDir}`; `ExecStart` = `lindexer watch -corpus … -index ${stateDir}/lindenIndex -state-dir ${stateDir}`; `Restart = on-failure`
- [ ] 1.3 Order it `after`/`requires` `secondbrain-clone.service` and `before` `linny-mcp.service`; `wantedBy = multi-user.target`

## 2. Evaluation checks (pre-deploy)

- [ ] 2.1 `nix eval` dapperehaan `systemd.services.linny-mcp-index.serviceConfig.ExecStart` → uses `lindexer watch`
- [ ] 2.2 `nix eval` the ExecStartPre → uses `lindexer build` with the state-dir/index paths

## 3. Deploy

- [ ] 3.1 Deploy dapperehaan over LAN `192.168.2.22`

## 4. Verification

- [ ] 4.1 `linny-mcp-index` service active; `index.sqlite` populated (multi-MB), rebuilt by the service (not the manual build)
- [ ] 4.2 Round-trip: edit a note on GitHub → git-sync pulls → index rebuilds → note searchable via MCP (no manual reindex)
- [ ] 4.3 `/var/lib/secondbrain` git working tree shows no index artifacts (lindenIndex/sqlite not tracked)
- [ ] 4.4 healthz still `ok`; MCP client still lists documents
