import { execAsync } from "ags/process"
import { createPoll } from "ags/time"

// Tri-state ssh-agent key indicator.
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

// tooltip needs the fingerprint; kept as a separate (slow) poll so the state
// poll stays a single word.
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

  return (
    <box
      class={state((s) => `StatusIcon SshKey ${s}`)}
      tooltipText={state((s) => {
        switch (s) {
          case "loaded":
            return `SSH key loaded — ${fingerprint.get()}`
          case "unloaded":
            return "SSH key not loaded — click to load"
          case "noagent":
            return "ssh-agent unreachable"
        }
      })}
    >
      <button
        onClicked={() => {
          if (state.get() !== "unloaded") return // no-op when loaded or no-agent
          // ssh-add runs detached (no controlling tty), so the passphrase prompt
          // must come from an askpass helper. SSH_ASKPASS is pinned to a
          // standalone askpass by the mipbar home-manager module and inherited
          // here (gcr's own askpass refuses standalone use); force ssh-add to
          // use it. SSH_AUTH_SOCK is inherited from the session.
          // The 5s poll picks up the loaded state; no manual re-poll needed.
          execAsync(["bash", "-c",
            "SSH_ASKPASS_REQUIRE=force ssh-add ~/.ssh/id_ed25519",
          ]).catch(() => {})
        }}
      >
        <label label={state((s) => ICON[s])} />
      </button>
    </box>
  )
}
