# Design

## Context

fprintd is enabled on delliebellie by `inputs.nixos-hardware.nixosModules.dell-xps-13-9315`. With `services.fprintd.enable`, NixOS sets `security.pam.services.<name>.fprintAuth` to true for every service, so `pam_fprintd` lands as `sufficient` before `pam_unix`. Its order inside a PAM stack is fixed: finger first, then password.

`/etc/pam.d/hyprlock` today:

```
auth sufficient pam_fprintd.so
auth sufficient pam_unix.so likeauth try_first_pass
auth required   pam_deny.so
```

hyprlock (0.9.5 here) runs PAM after the user submits the input field. The typed password sits in the conversation, but `pam_fprintd` runs first and blocks until a finger is read. The result is "password, then finger".

## Goals / Non-Goals

**Goals:** unlock the lock screen with the password or the fingerprint, either one alone. sudo and polkit ask for the password straight away.

**Non-Goals:** a fingerprint for sudo or polkit (that would need a parallel PAM module such as `pam-fprint-grosshack`, which is not in nixpkgs). GDM login stays as it is.

## Decisions

### hyprlock's own fingerprint support instead of PAM

hyprlock has a fingerprint backend that talks to fprintd over D-Bus and runs next to its PAM backend:

```
auth {
    pam {
        enabled = true
    }
    fingerprint {
        enabled = true
    }
}
```

Whichever backend succeeds first unlocks. With `security.pam.services.hyprlock.fprintAuth = false` the PAM backend checks the password only, so the two do not compete for the reader.

Alternative: keep `pam_fprintd` with a short timeout. That would still run in sequence and makes a typed password wait.

### sudo and polkit-1 lose pam_fprintd

```nix
security.pam.services = {
  hyprlock.fprintAuth = false;
  sudo.fprintAuth = false;
  polkit-1.fprintAuth = false;
};
```

These go in `desktop-de-hyprland`, next to `programs.hyprlock.enable`, which owns the hyprlock PAM service. On hosts without fprintd, `fprintAuth` is already false, so the setting is a no-op there.

### Placeholder text

The input field's `placeholder_text` becomes `<i>Password or finger...</i>`. `$FPRINTPROMPT` / `$FPRINTFAIL` exist in hyprlock but would show fprintd messages on hosts without a reader too; a fixed text is simpler.

## Risks / Trade-offs

- [hyprlock's fingerprint backend holds the reader while the lock screen is up] → nothing else needs the reader at that moment.
- [Fingerprint backend fails to start on hosts without fprintd] → hyprlock logs it and the password path keeps working; verify on a host without a reader.
- [After resume the reader may need a moment] → hyprlock restarts the fingerprint verify after a failure; check it after a suspend on delliebellie.
