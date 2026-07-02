import { Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { createPoll } from "ags/time"

// Tri-state ssh-agent key indicator with a click-through popover.
//
// The "my key" predicate is the SHA256 fingerprint of ~/.ssh/id_ed25519.pub,
// derived at runtime (not the comment): the file comment and the comment the
// agent reports can differ across machines, but the fingerprint is stable and
// survives key rotation.
//
// ssh-add -l exit codes: 0 = has identities, 1 = agent up but empty, 2 = agent
// unreachable. We only special-case 2 (no-agent); the loaded/unloaded split is
// decided by whether the fingerprint is present in the listing.
const POLL_SCRIPT = `
fp=$(ssh-keygen -lf ~/.ssh/id_ed25519.pub 2>/dev/null | awk '{print $2}')
out=$(ssh-add -l 2>/dev/null); rc=$?
if   [ "$rc" -eq 2 ]; then echo noagent
elif printf '%s\\n' "$out" | grep -qF "$fp"; then echo loaded
else echo unloaded
fi`

// Fingerprint for the tooltip / popover; slow poll (it rarely changes).
const FP_SCRIPT = `ssh-keygen -lf ~/.ssh/id_ed25519.pub 2>/dev/null | awk '{print $2}'`

const ICON = {
  loaded: "󰌾", // solid/closed lock
  unloaded: "󰿆", // open lock
  noagent: "󰗤", // cross
} as const

type State = keyof typeof ICON

function normalizeState(s: string): State {
  const t = s.trim()
  return t === "loaded" || t === "unloaded" || t === "noagent" ? t : "noagent"
}

export default function SshKey() {
  const state = createPoll("noagent", 5000, ["bash", "-c", POLL_SCRIPT], normalizeState)
  const fingerprint = createPoll("", 60000, ["bash", "-c", FP_SCRIPT], (s) => s.trim())

  const load = () =>
    // ssh-add runs detached (no controlling tty), so the passphrase prompt must
    // come from an askpass. SSH_ASKPASS is pinned to a standalone askpass by the
    // mipbar home-manager module and inherited here (gcr's own askpass refuses
    // standalone use); force ssh-add to use it. SSH_AUTH_SOCK is inherited.
    // The 5s poll flips the icon once the key is in the agent.
    execAsync(["bash", "-c", "SSH_ASKPASS_REQUIRE=force ssh-add ~/.ssh/id_ed25519"])
      .catch(() => {})

  const unload = () =>
    execAsync(["bash", "-c", "ssh-add -d ~/.ssh/id_ed25519"]).catch(() => {})

  return (
    <menubutton class={state((s) => `StatusIcon SshKey ${s}`)}>
      <label label={state((s) => ICON[s])} />
      <popover>
        <box orientation={Gtk.Orientation.VERTICAL} class="SshKeyPopover">
          <box class="StatusRow">
            <label
              class="SshKeyState"
              hexpand
              halign={Gtk.Align.START}
              label={state((s) => {
                switch (s) {
                  case "loaded": return "SSH key loaded"
                  case "unloaded": return "SSH key not loaded"
                  case "noagent": return "ssh-agent unreachable"
                }
              })}
            />
            <button
              class="ActionSmall"
              visible={state((s) => s === "loaded" || s === "unloaded")}
              onClicked={() => (state.get() === "loaded" ? unload() : load())}
            >
              <label label={state((s) => (s === "loaded" ? "Unload" : "Load"))} />
            </button>
          </box>
          <label
            class="SshKeyFingerprint"
            visible={state((s) => s === "loaded")}
            halign={Gtk.Align.START}
            label={fingerprint}
          />
        </box>
      </popover>
    </menubutton>
  )
}
