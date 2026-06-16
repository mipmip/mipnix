---
# mipnix-zxbi
title: 'mip fails to launch: ambient CAP_SYS_NICE breaks bwrap sandbox'
status: todo
type: bug
priority: normal
tags:
    - mip
    - bwrap
    - tmux
created_at: 2026-06-09T12:50:21Z
updated_at: 2026-06-09T12:50:21Z
---

## Symptom

Launching `mip` aborts before the window opens:

```
(process:NNN): Gdk-WARNING: Failed to read portal settings:
  GDBus.Error:org.freedesktop.DBus.Error.AccessDenied: Portal operation
  not allowed: Unable to open /proc/NNN/root
bwrap: Unexpected capabilities but not setuid, old file caps config?
(mip:NNN): ERROR: Failed to fully launch dbus-proxy: Child process exited with code 1
```

`mip` (0.4.3, a WebKitGTK app) spawns `bwrap` + `dbus-proxy` to sandbox its web
content process. The fatal line is the `bwrap` one — the portal warning is just
noise from the same broken sandbox attempt.

## Root cause

The shell `mip` is launched from carries an **ambient Linux capability
`CAP_SYS_NICE`** (`CapAmb=0x800000`). Ambient caps propagate to every child, so
`mip` and the `bwrap` it spawns inherit it. WebKitGTK's bubblewrap refuses to run
when it sees unexpected capabilities on a non-setuid process and aborts — exactly
`bwrap: Unexpected capabilities but not setuid, old file caps config?`.

Reproduced directly:

```
# WITH inherited cap (current shell):
$ bwrap --ro-bind / / --dev /dev true
bwrap: Unexpected capabilities but not setuid, old file caps config?   # exit 1

# After stripping ambient + inheritable caps:
$ setpriv --inh-caps -all --ambient-caps -all -- bwrap --ro-bind / / --dev /dev true
# exit 0  (CapInh/CapAmb/CapEff all zero)
```

Capability bitmasks observed in the affected shell:
- CapAmb = 0x800000  -> bit 23 = CAP_SYS_NICE
- CapInh = 0x800100  -> CAP_SYS_NICE + bit 8 (CAP_SETPCAP)

## Where the cap comes from

NOT from declared config. Verified all clean:
- No `pam_cap` in /etc/pam.d, no /etc/security/capability.conf
- `user@1000.service` has `AmbientCapabilities=` (empty)
- ghostty + tmux + hyprland binaries have NO file caps (`getcap` empty)
- Ghostty and Hyprland processes both have `CapAmb=0`
- No CAP_SYS_NICE / ambientCapabilities reference in /etc/nixos

The cap first appears at the **tmux server** layer. The running tmux server
(started ~9 jun) has `CapAmb=0x800000` and has reparented to init (PPid=1), so
the original launcher is gone. Conclusion: a **stale tmux server** inherited the
cap from an earlier ad-hoc session (e.g. a manual capsh/setpriv experiment) and
keeps passing it to all children (fish -> claude -> zsh -> mip).

Process tree (cap propagation):
```
tmux: server   CapAmb=0x800000  (reparented to init)
  fish         CapAmb=0x800000
    claude       CapAmb=0x800000
      zsh         CapAmb=0x800000  <- launches mip, inherits cap
```

## Fixes

**Immediate, no disruption** — strip the cap for the one launch:
```
setpriv --inh-caps -all --ambient-caps -all -- mip <args>
```

**Permanent for the session** — restart the tmux server from a clean shell
(Ghostty itself has CapAmb=0). Save work first; this closes all tmux sessions:
```
tmux kill-server
```
Then open a fresh Ghostty window, start tmux — new server has CapAmb=0 and mip
launches normally.

## Possible durable mitigation (mipnix)

Since the cap isn't declared anywhere in the Nix config, the real fix is just not
re-launching tmux with the cap. If it recurs, consider wrapping `mip` (fish func
or ~/.local/bin/mip shim) with the `setpriv` cap-strip so the sandbox is always
clean regardless of session lineage.
