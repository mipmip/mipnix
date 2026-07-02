import { Gtk } from "ags/gtk4"
import { createState } from "ags"
import { execAsync } from "ags/process"
import { createPoll, interval } from "ags/time"

// Four-state ssh-agent key indicator with a click-through popover.
//
// The "my key" predicate is the SHA256 fingerprint of ~/.ssh/id_ed25519.pub,
// derived at runtime (not the comment): the file comment and the comment the
// agent reports can differ across machines, but the fingerprint is stable and
// survives key rotation.
//
// Crucially, "listed in `ssh-add -l`" does NOT mean "usable": the gcr agent can
// keep a passphrase-protected key in its listing while being unable to actually
// sign with it (it hangs on the sign request), so SSH auth stalls right after
// "Server accepts key". So `loaded` requires that the agent can *sign*
// (`ssh-add -T`, bounded by `timeout` so a hung agent can't stall the poll); a
// listed-but-can't-sign key is reported as `stale` and click-to-load re-runs
// `ssh-add` to properly unlock it.
//
// ssh-add -l exit codes: 0 = has identities, 1 = agent up but empty, 2 = agent
// unreachable (the no-agent branch). ssh-add -T: 0 = signed, non-zero/timeout =
// cannot sign.
const POLL_SCRIPT = `
fp=$(ssh-keygen -lf ~/.ssh/id_ed25519.pub 2>/dev/null | awk '{print $2}')
out=$(ssh-add -l 2>/dev/null); rc=$?
if   [ "$rc" -eq 2 ]; then echo noagent
elif ! printf '%s\\n' "$out" | grep -qF "$fp"; then echo unloaded
elif timeout 4 ssh-add -T ~/.ssh/id_ed25519.pub >/dev/null 2>&1; then echo loaded
else echo stale
fi`

// Fingerprint for the tooltip / popover; slow poll (it rarely changes).
const FP_SCRIPT = `ssh-keygen -lf ~/.ssh/id_ed25519.pub 2>/dev/null | awk '{print $2}'`

const ICON = {
  loaded: "󰿆", // open lock — key IS loaded (unlocked/available)
  unloaded: "󰌾", // closed lock — key NOT loaded (locked away)
  stale: "󰦝", // lock with alert — listed but can't sign
  noagent: "󰗤", // cross
} as const

type State = keyof typeof ICON

function normalizeState(s: string): State {
  const t = s.trim()
  return t === "loaded" || t === "unloaded" || t === "stale" || t === "noagent"
    ? t
    : "noagent"
}

export default function SshKey() {
  // State is managed manually (not createPoll) so load/unload can force an
  // immediate refresh — createPoll's accessor has no public re-poll method, so
  // relying on its interval left the icon/button stale for up to 5s after an
  // action, which made the just-unloaded key impossible to reload from the
  // popover.
  const [state, setState] = createState<State>("noagent")
  const fingerprint = createPoll("", 60000, ["bash", "-c", FP_SCRIPT], (s) => s.trim())

  const refresh = () =>
    execAsync(["bash", "-c", POLL_SCRIPT])
      .then((out) => setState(normalizeState(out)))
      .catch(() => {})

  // Periodic poll (also fires immediately), consistent with other indicators.
  interval(5000, refresh)

  // Guard against firing a second ssh-add (and thus a second askpass popup)
  // while one is already in flight — e.g. a double click, or the popover button
  // re-triggering. The askpass GUI must appear exactly once per click.
  let inFlight = false
  const runOnce = (cmd: string) => {
    if (inFlight) return
    inFlight = true
    execAsync(["bash", "-c", cmd])
      .then(refresh)
      .catch(refresh)
      .finally(() => {
        inFlight = false
      })
  }

  const load = () =>
    // ssh-add runs detached from the bar (no controlling tty), so the passphrase
    // prompt must come from an askpass. The askpass env is set ONLY here (not as
    // a session-wide variable) so the GUI popup appears solely on a widget click
    // — a plain `ssh`/`ssh-add` in a terminal still prompts on its own tty.
    // ASKPASS is the standalone askpass path injected at bundle time (flake.nix).
    // SSH_AUTH_SOCK is inherited (the plain ssh-agent, via the session env).
    runOnce(
      `SSH_ASKPASS='${ASKPASS}' SSH_ASKPASS_REQUIRE=force ssh-add ~/.ssh/id_ed25519 < /dev/null`,
    )

  const unload = () => runOnce("ssh-add -d ~/.ssh/id_ed25519")

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
                  case "stale": return "SSH key listed but can't sign"
                  case "noagent": return "ssh-agent unreachable"
                }
              })}
            />
            <button
              class="ActionSmall"
              visible={state((s) => s !== "noagent")}
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
