## 1. PAM

- [ ] 1.1 Set `security.pam.services.{hyprlock,sudo,polkit-1}.fprintAuth = false` in `modules/programs/desktop/de/hyprland.nix`
- [ ] 1.2 Build delliebellie and check that `/etc/pam.d/hyprlock`, `sudo` and `polkit-1` in the result have no `pam_fprintd.so`, and that `gdm-fingerprint` still exists

## 2. hyprlock

- [ ] 2.1 Add the `auth { pam { enabled = true } fingerprint { enabled = true } }` block to `modules/USERS/pim/programs/hyprland/hypr/hyprlock.conf`
- [ ] 2.2 Change `placeholder_text` to `<i>Password or finger...</i>`

## 3. Rollout and checks

- [ ] 3.1 Commit, `rme up_machine` and `rme up_home` on delliebellie
- [ ] 3.2 `sudo true` prompts for the password at once
- [ ] 3.3 User: lock the screen, unlock with the finger only
- [ ] 3.4 User: lock the screen, unlock with the password only
- [ ] 3.5 User: suspend, resume, unlock with the finger
- [ ] 3.6 User: a polkit prompt asks for the password only
