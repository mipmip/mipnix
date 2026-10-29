## 1. Firefox setting

- [x] 1.1 Add `"media.webrtc.camera.allow-pipewire" = true` to `defaultSettings` in `modules/USERS/pim/programs/firefox.nix`; verify the home-manager build for delliebellie succeeds and the generated `user.js` contains the pref

## 2. Verification

- [x] 2.1 On delliebellie, in a fresh Firefox profile with the pref, request the camera from a test page; verify one camera entry ("Built-in Front Camera"), a live preview, and that this Firefox process does not appear in `lsof /dev/video*`
- [x] 2.2 Close that Firefox; verify `pw-dump` shows no camera users within a few seconds
- [x] 2.3 With a USB webcam (Razer Kiyo, UVC) on delliebellie, request that camera in the same Firefox profile; verify both cameras are listed, a live preview, and only `pipewire` holds the device

## Workflow follow-up

- Archive the change and add the `openspec-link` to bean `mipnix-4s6t`.
- Set bean `mipnix-4s6t` to `completed`.
- After the home-manager switch, restart Firefox so the running session picks up the pref.
