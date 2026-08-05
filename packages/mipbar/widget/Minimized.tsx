import Hyprland from "gi://AstalHyprland"
import { Gtk } from "ags/gtk4"
import { createState, For } from "ags"
import { execAsync } from "ags/process"
import { lookupIcon } from "./utils"

// Minimized-windows indicator.
//
// The mipbar `hypr-longpress` "Minimize" action moves a window to the
// `special:minimized` special workspace (`movetoworkspacesilent
// special:minimized,<addr>`). Nothing else surfaces or restores those windows,
// so this widget lists them and restores on click. It keys off the literal
// workspace NAME "special:minimized" (matched to that action), not the numeric
// id (which is negative and not guaranteed stable).
//
// Restore brings the window to the CURRENT workspace and focuses it —
// `special:minimized` records no origin, so "bring it here" is the predictable,
// dependency-free behavior.
const MINIMIZED_WS = "special:minimized"

type MinItem = {
  address: string
  title: string
  iconName: string
}

function getMinimized(hyprland: Hyprland.Hyprland): MinItem[] {
  const ws = hyprland.get_workspaces().find((w) => w.get_name() === MINIMIZED_WS)
  if (!ws) return []
  return ws.get_clients().map((c) => ({
    // AstalHyprland's get_address() returns the address WITHOUT the `0x` prefix
    // (e.g. "61fed…"), but `hyprctl dispatch … address:<addr>` requires the
    // `0x` form or it fails with "No such window found". Normalize to `0x…`.
    address: withHexPrefix(c.get_address()),
    title: c.get_title() || c.get_class() || "window",
    iconName: lookupIcon(c.get_class() || "") || "application-x-executable",
  }))
}

function withHexPrefix(addr: string): string {
  return addr.startsWith("0x") ? addr : `0x${addr}`
}

export default function Minimized() {
  const hyprland = Hyprland.get_default()
  const [items, setItems] = createState<MinItem[]>(getMinimized(hyprland))

  const refresh = () => setItems(getMinimized(hyprland))

  // Same signals Workspaces.tsx listens to, so the list/count/visibility track
  // minimize and restore events without polling.
  hyprland.connect("client-added", refresh)
  hyprland.connect("client-removed", refresh)
  hyprland.connect("client-moved", refresh)
  hyprland.connect("notify::workspaces", refresh)

  const restore = (address: string) => {
    const wsId = hyprland.get_focused_workspace()?.id
    if (wsId === undefined) return
    // Move to the current workspace, then focus it.
    execAsync(["bash", "-c",
      `hyprctl dispatch movetoworkspace "${wsId},address:${address}" && ` +
      `hyprctl dispatch focuswindow "address:${address}"`,
    ]).then(refresh).catch(refresh)
  }

  const restoreAll = () => {
    for (const it of items.get()) restore(it.address)
  }

  return (
    <menubutton
      visible={items((list) => list.length > 0)}
      class="StatusIcon Minimized"
      tooltipText={items((list) => `${list.length} minimized`)}
    >
      <box>
        <label class="MinimizedIcon" label="󰖰" />
        <label class="MinimizedCount" label={items((list) => String(list.length))} />
      </box>
      <popover>
        <box orientation={Gtk.Orientation.VERTICAL} class="MinimizedPopover">
          <For each={items}>
            {(item: MinItem) => (
              <button
                class="MinimizedRow"
                onClicked={() => restore(item.address)}
              >
                <box>
                  <image iconName={item.iconName} />
                  <label
                    label={item.title.length > 48 ? item.title.slice(0, 47) + "…" : item.title}
                    hexpand
                    halign={Gtk.Align.START}
                    maxWidthChars={48}
                    ellipsize={3 /* PANGO_ELLIPSIZE_END */}
                  />
                </box>
              </button>
            )}
          </For>
          <Gtk.Separator />
          <button class="ActionSmall RestoreAll" onClicked={restoreAll}>
            <label label="Restore all" />
          </button>
        </box>
      </popover>
    </menubutton>
  )
}
