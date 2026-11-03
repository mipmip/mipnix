# Design

## Context

`lobby` without arguments already starts a `gum filter` picker on a terminal and opens the chosen service with `xdg-open "$1" &`. tmux bindings live in `flake.hotkeys` in `modules/USERS/pim/programs/tmux/binds.nix`; tools open as `popup -E ...`, which closes the popup when the command exits.

## Goals / Non-Goals

**Goals:** one key from tmux to a service page, popup gone afterwards; the picker shows only services with something to look at.

**Non-Goals:** opening a browser on the local desktop from tmux on a remote host over ssh; a separate popup wrapper script.

## Decisions

### Binding

```nix
{ kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
  group = "tools"; key = "W"; desc = "lobby, open a service";
  action = "popup -E -w 60% -h 60% 'lobby'"; }
```

`W` is free in the prefix table. `L` would have been the mnemonic, but tmux binds it to `switch-client -l`.

### setsid -f

With `-E`, tmux closes the popup's pty when `lobby` exits, and a background `xdg-open` gets SIGHUP. If no browser is running yet, the start can break off. `setsid -f xdg-open "$1" >/dev/null 2>&1` puts it in its own session, outside the popup. The macOS branch (`open`) hands over and returns at once, so it stays as it is.

### browse field instead of a rule on access

A rule such as "hide `access = local`" would hide Syncthing, whose localhost GUI does work on every pool member, and would keep Tuwunel and linny-mcp, whose URLs are APIs. An explicit `browse` option (bool, default true) says it per service. The picker filters on `url != null and browse`. The field is added to the exported JSON; the web page ignores it.

| Service    | Why hidden                         |
|------------|------------------------------------|
| samba      | no URL                             |
| prometheus | 127.0.0.1 on dapperehaan           |
| tuwunel    | Matrix API, no page                |
| linny-mcp  | MCP endpoint, no page              |

### Errors in the popup

A service without a page no longer reaches the picker, so `open_service` errors cannot happen from the popup. Cancelling exits 0.

## Risks / Trade-offs

- [`setsid` missing on macOS] → only the Linux branch uses it.
- [A new service with an API URL appears in the picker until `browse = false` is set] → acceptable; it is one line next to the service.
