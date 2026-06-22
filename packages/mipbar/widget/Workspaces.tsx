import Hyprland from "gi://AstalHyprland"
import Gtk from "gi://Gtk?version=4.0"
import Gdk from "gi://Gdk?version=4.0"
import { createState, For } from "ags"
import { lookupIcon } from "./utils"
import { execAsync, exec } from "ags/process"
import { monitorAccent } from "./monitors"
import { openScreenPicker } from "./ScreenPicker"

type ClientInfo = {
  class: string
  title: string
  iconName: string
}

type WorkspaceItem = {
  id: number
  isGroupStart: boolean
  isLaptop: boolean
  clients: ClientInfo[]
  monitor: string | null
  accent: string
}

const WORKSPACE_IDS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
const LAPTOP_IDS = new Set([8, 9, 0])

function isDark(): boolean {
  try {
    return exec("gsettings get org.gnome.desktop.interface color-scheme").includes("prefer-dark")
  } catch {
    return true
  }
}

function getWorkspaceItems(hyprland: Hyprland.Hyprland): WorkspaceItem[] {
  const dark = isDark()
  const workspaceMap = new Map<number, Hyprland.Workspace>()
  for (const w of hyprland.get_workspaces()) {
    if (w.id >= 0) workspaceMap.set(w.id, w)
  }

  return WORKSPACE_IDS.map((id) => {
    const workspace = workspaceMap.get(id)
    const clients: ClientInfo[] = workspace
      ? workspace.get_clients().map((c) => ({
          class: c.class || "",
          title: c.title || "",
          iconName: lookupIcon(c.class || ""),
        }))
      : []

    // Group separator between workspace 7 and 8
    const isGroupStart = id === 8

    // Monitor the workspace is currently bound to → its accent for the underline.
    const monitor = workspace?.get_monitor()?.get_name() ?? null
    const accent = monitor ? monitorAccent(monitor, dark) : "transparent"

    return { id, isGroupStart, isLaptop: LAPTOP_IDS.has(id), clients, monitor, accent }
  })
}

export default function Workspaces() {
  const hyprland = Hyprland.get_default()

  const [items, setItems] = createState<WorkspaceItem[]>(getWorkspaceItems(hyprland))
  const [focusedId, setFocusedId] = createState<number>(
    hyprland.get_focused_workspace()?.id ?? -1,
  )

  const refresh = () => {
    setItems(getWorkspaceItems(hyprland))
    setFocusedId(hyprland.get_focused_workspace()?.id ?? -1)
  }

  // Existing client/workspace triggers.
  hyprland.connect("notify::workspaces", refresh)
  hyprland.connect("notify::focused-workspace", refresh)
  hyprland.connect("client-added", refresh)
  hyprland.connect("client-removed", refresh)
  hyprland.connect("client-moved", refresh)
  // New: recompute monitor underlines when monitors or bindings change.
  hyprland.connect("notify::monitors", refresh)
  hyprland.connect("monitor-added", refresh)
  hyprland.connect("monitor-removed", refresh)

  return (
    <box class="Workspaces">
      <For each={items}>
        {(item: WorkspaceItem) => {
          // Secondary (right) click opens the screen picker; does NOT switch workspace.
          const secondary = new Gtk.GestureClick()
          secondary.set_button(Gdk.BUTTON_SECONDARY)

          return (
            <button
              class={focusedId((fid) => {
                let cls = "WorkspaceButton"
                if (item.isGroupStart) cls += " group-start"
                if (item.isLaptop) cls += " laptop"
                if (fid === item.id) cls += " focused"
                return cls
              })}
              onClicked={() => execAsync(`hyprctl dispatch workspace ${item.id}`)}
              $={(self: Gtk.Widget) => {
                secondary.connect("pressed", () => openScreenPicker(hyprland, self, item.id))
                self.add_controller(secondary)
              }}
            >
              <box orientation={Gtk.Orientation.VERTICAL} spacing={4} halign={Gtk.Align.CENTER}>
                <box halign={Gtk.Align.CENTER}>
                  <label label={String(item.id)} />
                  {item.clients.map((client) => (
                    <image
                      class="AppIcon"
                      iconName={client.iconName || "application-x-executable"}
                      tooltipText={client.title}
                    />
                  ))}
                </box>
                <box
                  class="WorkspaceUnderline"
                  halign={Gtk.Align.CENTER}
                  $={(self: Gtk.Widget) => {
                    const css = new Gtk.CssProvider()
                    css.load_from_string(`.WorkspaceUnderline { background: ${item.accent}; }`)
                    self.get_style_context().add_provider(css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
                  }}
                />
              </box>
            </button>
          )
        }}
      </For>
    </box>
  )
}
