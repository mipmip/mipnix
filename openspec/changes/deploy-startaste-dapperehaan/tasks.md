## 1. Upstream prerequisites (startaste repo, not this one)

- [ ] 1.1 `startaste-zrap`: flake exposes `nixosModules.startaste` and
      `overlays.default`; verify by adding the input here and evaluating
      `nix flake show github:mipmip/startaste` to confirm both attributes exist
- [ ] 1.2 `startaste-hq9c`: SQLite opens in WAL mode; verify with
      `pragma journal_mode` on a synced database returning `wal`
- [ ] 1.3 `startaste-qbtu`: the MCP server exists, serves `/mcp` over streamable
      HTTP with bearer auth and an unauthenticated `/healthz`; verify locally
      before touching the host config

## 2. Secrets and flake wiring

- [ ] 2.1 Add the `startaste` flake input following nixpkgs, apply
      `overlays.default` and import `nixosModules.startaste` on dapperehaan;
      verify `nixos-rebuild build` for dapperehaan evaluates
- [ ] 2.2 Add `startaste-env.age` (holding `HN_COMMENTS_ACCT`,
      `HN_COMMENTS_PW`, `GITHUB_TOKEN`) to `secrets/secrets.nix` with recipients
      `[ pim dapperehaan ]`; verify it decrypts on the host to a file owned by
      the service user with mode `400`
- [ ] 2.3 Add `startaste-mcp-tokens.age` (hashed bearer-token records) with the
      same recipients; verify no token literal appears in any Nix option or in
      `/nix/store`
- [ ] 2.4 MANUAL: mint a scopeless GitHub token, collect the HN credentials, and
      populate `startaste-env.age`; verify `startaste sync github` succeeds on
      the host using only that env file

## 3. Scheduled sync (can land before the MCP server exists)

- [ ] 3.1 Confirm the upstream module's defaults suit this host: it creates
      `/var/lib/startaste` via tmpfiles, sets `STARTASTE_DATA` / `STARTASTE_DB`
      / `STARTASTE_LOG`, and puts them in `ReadWritePaths`; verify the unit
      starts without `226/NAMESPACE` and override `dataDir` only if needed
- [ ] 3.2 Set `services.startaste.sync.enable` with `environmentFile` from 2.2
      and `dataDir = "/var/lib/startaste"`; verify `systemctl start
      startaste-sync` populates the database and the run appears in the journal.
      The unit and its hardening come from the upstream module (startaste change
      `nixos-service-module`) — do not define them here
- [ ] 3.3 Set `services.startaste.sync.interval = "1h"`; verify
      `systemctl list-timers` shows the next elapse and that a second run does
      not start while one is in progress
- [ ] 3.4 Verify a failing run is visible: temporarily point at an invalid
      token, confirm non-zero exit and a journal entry, then restore

## 4. Dashboard, mesh only (after 1.2)

- [ ] 4.1 Set `services.startaste.dashboard.enable` with
      `listenAddress = "192.168.100.2"` (the module defaults to loopback);
      verify it is reachable from another nebula host and refuses to answer on a
      public interface
- [ ] 4.2 Verify no durer vhost proxies to it, and that reading the dashboard
      during a sync run does not raise a locked-database error

## 5. MCP endpoint (after 1.2 and 1.3)

- [ ] 5.1 Set `services.startaste.mcp.enable` with
      `listenAddress = "192.168.100.2"`, `port = 8766` (the module's default)
      and `tokensFile` from 2.3 — the unit comes from the upstream module
      (startaste change `mcp-server`), do not define it here; verify `/healthz`
      answers unauthenticated and `/mcp` rejects a request with no bearer token
- [ ] 5.2 MANUAL: create the `taste.pimsnel.com` DNS A-record pointing at durer;
      verify it resolves before requesting a certificate
- [ ] 5.3 Add the durer vhost modelled on
      `modules/HOSTS/durer-server/secondbrain.nix` (ACME, forceSSL,
      `proxyWebsockets`, `proxy_buffering off`, long read/send timeouts);
      verify `https://taste.pimsnel.com/healthz` returns over TLS
- [ ] 5.4 Verify the streamable transport is not buffered: an SSE response
      streams incrementally rather than arriving in one block at the end
- [ ] 5.5 MANUAL: mint a bearer token with `startaste mcp-token`, add its
      record to `startaste-mcp-tokens.age`, configure a Claude Online/Mobile MCP
      client, and verify a tool call round-trips against the real data

## 6. Verification

- [ ] 6.1 Confirm port allocation on dapperehaan's mesh IP has no collision:
      linny-mcp 8765, startaste MCP 8766, startaste dashboard 8421
- [ ] 6.2 Reboot dapperehaan and confirm the timer resumes, both long-running
      units come back, and the database is intact
- [ ] 6.3 Confirm every credential path is agenix-sourced: grep the evaluated
      configuration for the token and password values and find nothing
