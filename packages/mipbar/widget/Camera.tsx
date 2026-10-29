import AstalWp from "gi://AstalWp"
import Gtk from "gi://Gtk?version=4.0"
import { createState } from "ags"
import { execAsync } from "ags/process"
import { interval, timeout } from "ags/time"
import {
  type CameraState,
  type CameraUser,
  focusable,
  mergeUsers,
  normalizeName,
  parseLsof,
  parsePwDump,
  tooltipText,
} from "./cameraUsers"

async function pipewireState(): Promise<CameraState> {
  try {
    return parsePwDump(await execAsync("pw-dump"))
  } catch {
    return { active: false, users: [] }
  }
}

async function directUsers(): Promise<CameraUser[]> {
  const out = await execAsync(["bash", "-c", "lsof -Fpc /dev/video* 2>/dev/null || true"]).catch(() => "")
  return Promise.all(
    parseLsof(out).map(async (user) => {
      const cmdline = await execAsync(["cat", `/proc/${user.pid}/cmdline`]).catch(() => "")
      const name = normalizeName(cmdline.split("\0")[0])
      return name ? { ...user, name } : user
    }),
  )
}

function focus(user: CameraUser) {
  if (user.pid !== null) execAsync(`hyprctl dispatch focuswindow pid:${user.pid}`)
}

function showMenu(button: Gtk.Widget, users: CameraUser[]) {
  const popover = new Gtk.Popover()
  popover.add_css_class("CameraPopover")
  popover.set_parent(button)
  popover.set_position(Gtk.PositionType.BOTTOM)

  const list = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL })
  for (const user of users) {
    const row = new Gtk.Button({ label: user.name || `pid ${user.pid}` })
    row.add_css_class("CameraRow")
    row.connect("clicked", () => {
      focus(user)
      popover.popdown()
    })
    list.append(row)
  }

  popover.set_child(list)
  popover.connect("closed", () => popover.unparent())
  popover.popup()
}

export default function Camera() {
  const [camera, setCamera] = createState<CameraState>({ active: false, users: [] })

  const refresh = async () => {
    const [pw, direct] = await Promise.all([pipewireState(), directUsers()])
    setCamera({ active: pw.active || direct.length > 0, users: mergeUsers(pw.users, direct) })
  }

  const refreshSoon = () => {
    refresh()
    timeout(1000, refresh)
  }

  const video = AstalWp.get_default()?.video
  if (video) {
    for (const signal of ["recorder-added", "recorder-removed", "source-added", "source-removed"]) {
      video.connect(signal, refreshSoon)
    }
  }
  interval(5000, refresh)

  return (
    <box visible={camera((c) => c.active)} class="StatusIcon Camera" tooltipText={camera(tooltipText)}>
      <button
        onClicked={(self) => {
          const users = focusable(camera.get().users)
          if (users.length === 1) focus(users[0])
          else if (users.length > 1) showMenu(self, users)
        }}
      >
        <image iconName="camera-web-symbolic" />
      </button>
    </box>
  )
}
