import { createState } from "ags"
import { execAsync } from "ags/process"
import { interval } from "ags/time"

// Keep-awake toggle, the espresso/caffeine idea.
//
// What it actually holds off is hypridle, not suspend. This session never
// suspends on its own (logind IdleAction=ignore, see hypridle.conf), so the
// things that fire on idle are hypridle's two listeners: lock at 10 minutes and
// DPMS off at 15. hypridle honours logind's idle inhibitors as long as
// `ignore_systemd_inhibit` is left at its default, which this configuration
// does, so a `systemd-inhibit --what=idle` lock is enough to stop both.
//
// `--what=idle` only. Adding `sleep` would make the lock also block an
// explicit `systemctl suspend`, which is bound to Super+Shift+L, so asking to
// stay awake would quietly break asking to sleep. Lid close still suspends.
//
// The lock lives in a transient user unit rather than in a child of the bar, so
// that it survives a bar reload and so the truth can be read back from systemd
// instead of tracked in a variable that a reload would reset. `systemd-inhibit
// --list` shows it like any other.
const UNIT = "mipbar-caffeine"

// reset-failed first: a unit left behind in a failed state makes systemd-run
// refuse the name, and the toggle would then silently do nothing.
const START = `
systemctl --user reset-failed ${UNIT} 2>/dev/null
exec systemd-run --user --unit=${UNIT} --description='mipbar keep-awake' \
  systemd-inhibit --what=idle --who=mipbar --why='Keep awake (mipbar)' \
  --mode=block sleep infinity`

const ICON = {
  on: "󰅶", // coffee cup — idle is inhibited
  off: "󰛊", // crossed-out cup — normal idle behaviour
} as const

type State = keyof typeof ICON

export default function Caffeine() {
  const [state, setState] = createState<State>("off")

  // `systemctl is-active` exits non-zero when the unit is not running, and
  // execAsync rejects on a non-zero exit, so "inactive" arrives as a rejection
  // rather than as output.
  const refresh = () =>
    execAsync(["systemctl", "--user", "is-active", UNIT])
      .then((out) => setState(out.trim() === "active" ? "on" : "off"))
      .catch(() => setState("off"))

  // Also catches the unit stopping by any other route, a `systemctl --user
  // stop` typed by hand included.
  interval(5000, refresh)

  // A second click while the first is still in flight would race start against
  // stop and leave the unit in whichever state finished last.
  let inFlight = false
  const toggle = () => {
    if (inFlight) return
    inFlight = true
    const cmd = state.get() === "on"
      ? ["systemctl", "--user", "stop", UNIT]
      : ["bash", "-c", START]
    execAsync(cmd)
      .then(refresh)
      .catch(refresh)
      .finally(() => {
        inFlight = false
      })
  }

  return (
    <box class={state((s) => `StatusIcon Caffeine ${s}`)}>
      <button
        onClicked={toggle}
        tooltipText={state((s) =>
          s === "on"
            ? "Keeping the screen awake — click to allow idle lock again"
            : "Idle lock and screen blanking are active — click to keep awake"
        )}
      >
        <label label={state((s) => ICON[s])} />
      </button>
    </box>
  )
}
