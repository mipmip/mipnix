import Hyprland from "gi://AstalHyprland"
import { createState } from "ags"
import { execAsync } from "ags/process"

async function queryScreenshareProcess(): Promise<{ name: string; pid: string } | null> {
  try {
    // List portal sessions to find screenshare requestors
    const tree = await execAsync(
      "busctl --user tree org.freedesktop.portal.Desktop --no-pager"
    )
    // Parse session paths: /org/freedesktop/portal/desktop/session/1_418/obs1
    const sessions = tree.split("\n")
      .map((l) => l.replace(/[│├└─ ]/g, "").trim())
      .filter((l) => l.startsWith("/org/freedesktop/portal/desktop/session/"))

    // Find leaf session tokens (deepest paths) and their D-Bus senders
    const leaves = sessions.filter((s) => {
      const parts = s.replace("/org/freedesktop/portal/desktop/session/", "").split("/")
      return parts.length === 2
    })

    // Try each session, prefer non-gtk ones (gtk sessions are usually file choosers)
    const nonGtk = leaves.filter((s) => !s.includes("/gtk"))
    const candidates = nonGtk.length > 0 ? nonGtk : leaves

    if (candidates.length === 0) return null

    // Use the last candidate (most recent)
    const session = candidates[candidates.length - 1]
    const senderPart = session
      .replace("/org/freedesktop/portal/desktop/session/", "")
      .split("/")[0]
    const dbusName = `:${senderPart.replace("_", ".")}`

    // Get PID from D-Bus sender
    const status = await execAsync(`busctl --user status ${dbusName} --no-pager`)
    const pidMatch = status.match(/^PID=(\d+)/m)
    if (!pidMatch) return null

    const pid = pidMatch[1]
    // Use cmdline instead of comm (comm is truncated to 15 chars)
    const cmdline = await execAsync(`cat /proc/${pid}/cmdline`).then((s) => s.split("\0")[0])
    const basename = cmdline.split("/").pop() || "Unknown"
    // NixOS wraps binaries: ".obs-wrapped" → "obs", ".firefox-wrapped" → "firefox"
    const name = basename.replace(/^\./, "").replace(/-wrapped$/, "")

    return { name, pid }
  } catch {
    return null
  }
}

export default function Screenshare() {
  const hyprland = Hyprland.get_default()
  const [active, setActive] = createState(false)
  const [processName, setProcessName] = createState("")
  const [processPid, setProcessPid] = createState("")

  hyprland.connect("event", (_: any, event: string, args: string) => {
    if (event === "screencast") {
      const [state] = args.split(",")
      const isActive = state === "1"
      setActive(isActive)

      if (isActive) {
        // Small delay to let PipeWire set up the stream
        setTimeout(() => {
          queryScreenshareProcess().then((info) => {
            setProcessName(info?.name || "")
            setProcessPid(info?.pid || "")
          })
        }, 500)
      } else {
        setProcessName("")
        setProcessPid("")
      }
    }
  })

  return (
    <box
      visible={active}
      class="StatusIcon Screenshare"
      tooltipText={processName((name) =>
        name ? `Sharing: ${name}` : "Screen sharing active"
      )}
    >
      <button
        onClicked={() => {
          const pid = processPid.get()
          if (pid) {
            execAsync(`hyprctl dispatch focuswindow pid:${pid}`)
          }
        }}
      >
        <image iconName="camera-web-symbolic" />
      </button>
    </box>
  )
}
