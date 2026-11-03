# Proposal

## Why

Opening a service from the lobby means switching to a shell, typing `lobby` and picking. A tmux key that opens the picker in a popup, opens the choice in the browser and closes again is faster. The picker also offers services that have nothing to open in a browser, such as samba (no URL), Prometheus (localhost on dapperehaan) and Tuwunel (a Matrix API).

## What Changes

- New tmux binding `prefix + W` that runs `lobby` in a popup. The popup closes as soon as a service is opened or the picker is cancelled with Escape.
- `lobby` starts the browser with `setsid -f xdg-open`, so the browser survives the popup closing.
- New registry field `browse` (bool, default true). The picker shows only services with a URL and `browse = true`. `lobby list`, `lobby show` and the web page keep showing everything.
- `browse = false` for prometheus, tuwunel and linny-mcp. samba is left out because it has no URL.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `lobby`: the `lobby` command's picker offers browsable services only and opens them detached; a new requirement for the tmux popup.

## Impact

- `modules/lobby/option.nix`: `browse` option, exported in the JSON.
- `packages/lobby/lobby.sh`: picker filter, `setsid -f` in `open_url`.
- `modules/USERS/pim/programs/tmux/binds.nix`: the `W` entry.
- `modules/services/monitoring/grafana.nix`, `modules/HOSTS/durer-server/configuration.nix`, `modules/HOSTS/dapperehaan-server/linny-mcp.nix`: `browse = false`.
- Rollout: `rme up_home` on pim's machines.
