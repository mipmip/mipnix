## Outcome: already satisfied, no code changes needed

Investigation showed the proposal's premise was wrong. `programs.mosh` in this nixpkgs has
`openFirewall` defaulting to **true**, so `programs.mosh.enable = true` (already in
`role-server`, commit 04c86972) ALSO opened `networking.firewall.allowedUDPPortRanges`
60000–61000 globally. mosh from `lego2` to `durer` works as-is (confirmed by the user). No
firewall rule, no client change, and no deploy were required.

## 1. Investigate (resolve open questions)

- [x] 1.1 `programs.mosh.enable` DOES open the firewall here: `programs.mosh.openFirewall` defaults to `true` and adds `allowedUDPPortRanges { from = 60000; to = 61000; }`. So the UDP range was never blocked — my earlier assumption was incorrect.
- [x] 1.2 Nebula interface would be `nebula.mesh` (from `services.nebula.networks.mesh`) — moot, since global opening already covers it.
- [x] 1.3 Transport path: not a blocking decision — the default global UDP-range opening works for both public and mesh paths. mosh confirmed working.

## 2. Open the mosh UDP range

- [x] 2.1 No change needed: the range is already opened globally by `programs.mosh` (openFirewall=true).
- [x] 2.2 `programs.mosh.enable = true` remains in `role-server` (unchanged).

## 3. Ensure the laptop client

- [x] 3.1 Confirmed working: mosh client is present on `lego2` (the user successfully ran a mosh session).

## 4. Build and deploy

- [x] 4.1 No new build required (no config change).
- [x] 4.2 No deploy required (already deployed via 04c86972).

## 5. Verify (acceptance)

- [x] 5.1 User confirmed an interactive `lego2 → durer` mosh session works.
- [x] 5.2 mosh roaming is inherent to a working mosh session (UDP range reachable).
- [x] 5.3 Scoping: the range is opened globally (openFirewall default). Note for follow-up if tighter scoping is ever wanted — see below.
