## 1. Prerequisites (before any Nix edit)

- [ ] 1.1 Mint one bearer token per client with
      `nix run github:mipmip/startaste -- mcp-token --name <client>` for
      `claude-online`, `claude-mobile` and `cli`; verify each run prints a raw
      token and a `{"name","hash","scopes"}` record, and store the raw tokens in
      the password manager (they are shown once).
- [ ] 1.2 Confirm the GitHub token is scopeless or Starring→read-only at
      github.com/settings/tokens, and that the HN credentials still authenticate;
      verify by running `startaste sync` locally once and seeing both sources
      report success.
- [ ] 1.3 Confirm `taste.pimsnel.com` resolves to durer with
      `dig +short taste.pimsnel.com A` — it SHALL match
      `dig +short secondbrain.pimsnel.com A`. (Verified at proposal time; re-check
      before deploying durer.)

## 2. Secrets

- [ ] 2.1 Add `"startaste-env.age".publicKeys = [ pim dapperehaan ];` and
      `"startaste-mcp-tokens.age".publicKeys = [ pim dapperehaan ];` to
      `secrets/secrets.nix`; verify with `nix eval -f secrets/secrets.nix --apply builtins.attrNames`
      (or by reading the file) that both entries are present and no other entry changed.
- [ ] 2.2 Create `secrets/startaste-env.age` with
      `cd secrets && agenix -e startaste-env.age -i ~/.ssh/id_ed25519`, holding plain
      `KEY=value` lines for `GITHUB_TOKEN`, `HN_COMMENTS_ACCT`, `HN_COMMENTS_PW` —
      no `export`, no inline comments, values with `#`/`$`/spaces single-quoted;
      verify by re-opening it with `agenix -e` and reading it back.
- [ ] 2.3 Create `secrets/startaste-mcp-tokens.age` the same way, holding a JSON
      list of the records minted in 1.1; verify the decrypted content parses with
      `python3 -m json.tool` and contains one record per client.

## 3. Flake input

- [ ] 3.1 Add `startaste.url = "github:mipmip/startaste"` with
      `startaste.inputs.nixpkgs.follows = "nixpkgs"` to `flake.nix`, next to the
      `linny-mcp` input; verify `nix flake metadata` lists the input and
      `flake.lock` gains a pinned entry.
- [ ] 3.2 Verify the input exposes what is needed:
      `nix eval .#inputs.startaste.nixosModules.startaste --apply builtins.typeOf`
      and the same for `overlays.default`, both resolving without error.

## 4. dapperehaan service

- [ ] 4.1 Create `modules/HOSTS/dapperehaan-server/startaste.nix` importing
      `inputs.startaste.nixosModules.startaste` and adding
      `inputs.startaste.overlays.default` to `nixpkgs.overlays`; verify the host
      evaluates with `nix eval .#nixosConfigurations.dapperehaan.config.services.startaste.enable`.
- [ ] 4.2 Declare the two `age.secrets` entries with `owner`/`group` `startaste`
      and `mode = "400"`, mirroring `linny-mcp.nix`; verify
      `nix eval .#nixosConfigurations.dapperehaan.config.age.secrets --apply builtins.attrNames`
      lists both.
- [ ] 4.3 Enable the service: `sync.enable` with the module's default interval,
      `mcp.enable` on `192.168.100.2:8766` with `tokensFile`, `dashboard.enable` on
      `192.168.100.2:8421`, and `environmentFile` pointing at the env secret's
      path; verify by evaluating those option values and confirming no listen
      address is `0.0.0.0` or public.
- [ ] 4.4 Verify the module's assertions are satisfied and no port collides:
      evaluate `config.systemd.services` names to confirm `startaste-sync`,
      `startaste-mcp` and `startaste-dashboard` exist alongside the untouched
      `linny-mcp`, and that 8765 / 8766 / 8421 are three distinct ports.
- [ ] 4.5 Wire the new module into dapperehaan's host configuration the same way
      `linny-mcp.nix` is wired; verify
      `nix build .#nixosConfigurations.dapperehaan.config.system.build.toplevel --dry-run`
      succeeds.

## 5. durer vhost

- [ ] 5.1 Create `modules/HOSTS/durer-server/taste.nix` with an `enableACME` +
      `forceSSL` vhost for `taste.pimsnel.com` proxying to
      `http://192.168.100.2:8766`, copying the SSE-safe `extraConfig` from
      `secondbrain.nix` verbatim; verify
      `nix eval .#nixosConfigurations.durer.config.services.nginx.virtualHosts --apply builtins.attrNames`
      lists `taste.pimsnel.com` and that `secondbrain.pimsnel.com` is unchanged.
- [ ] 5.2 Verify no vhost proxies to the dashboard port: grep the evaluated durer
      nginx config for `8421` and confirm no match.
- [ ] 5.3 Verify durer builds:
      `nix build .#nixosConfigurations.durer.config.system.build.toplevel --dry-run`.

## 6. Deploy and live verification

- [ ] 6.1 Deploy dapperehaan with `./RUNME.sh deploy_remote dapperehaan`; verify
      `systemctl status startaste-sync.timer startaste-mcp startaste-dashboard`
      shows the timer active and the two services present.
- [ ] 6.2 Trigger the first sync with `systemctl start startaste-sync` and verify
      via `journalctl -u startaste-sync` that both sources synced and
      `/var/lib/startaste/startaste.db` now exists owned by `startaste`.
- [ ] 6.3 Verify the cold-start behaviour matches the spec: check
      `journalctl -u startaste-mcp` shows it retried while the database was absent
      and is now `active (running)` without manual intervention.
- [ ] 6.4 Verify the mesh bind from another nebula node:
      `curl -sS http://192.168.100.2:8766/healthz` responds, and
      `curl -sS http://<dapperehaan-public-ip>:8766/healthz` does not.
- [ ] 6.5 Verify the dashboard is mesh-only: it loads at
      `http://192.168.100.2:8421` from a nebula node and is not reachable via any
      public address or vhost.
- [ ] 6.6 Deploy durer with `./RUNME.sh deploy_remote durer`; verify the ACME
      certificate for `taste.pimsnel.com` was issued
      (`systemctl status acme-taste.pimsnel.com`, cert present under
      `/var/lib/acme/taste.pimsnel.com/`).
- [ ] 6.7 Verify the public endpoint end to end: `curl -sS https://taste.pimsnel.com/healthz`
      succeeds with no credentials, and `curl -sS -o /dev/null -w '%{http_code}' https://taste.pimsnel.com/mcp`
      is rejected without an `Authorization` header.
- [ ] 6.8 Connect a real MCP client (Claude Online) to
      `https://taste.pimsnel.com/mcp` with one of the minted tokens and verify the
      tool list loads and a star search returns results from the synced database.
- [ ] 6.9 Verify per-client revocation: remove one record from
      `startaste-mcp-tokens.age`, redeploy, and confirm that client is rejected
      while another minted token still works. Restore the record afterwards.
- [ ] 6.10 Verify no regression in linny: `secondbrain.pimsnel.com/mcp` still
      authenticates and answers, and `linny-mcp.service` was not restarted or
      reconfigured by this deploy.
