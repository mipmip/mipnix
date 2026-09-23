import Hyprland from "gi://AstalHyprland"
import Gtk from "gi://Gtk?version=4.0"
import Gdk from "gi://Gdk?version=4.0"
import Pango from "gi://Pango"
import { createState, For } from "ags"
import { lookupIcon } from "./utils"

// All-windows picker.
//
// mipbar's workspace row can only render an allowlist of workspace ids
// (Workspaces.tsx WORKSPACES), but Hyprland's workspace space is open-ended: a
// 3-finger swipe past the last workspace, a dispatch to a named workspace, or a
// workspace bound to a monitor that is not connected all put a window somewhere
// the bar never draws. Such a window is then unreachable from the bar entirely.
//
// This widget is the safety net for that: it lists EVERY client, so a window
// shows up here whether or not the bar knows its workspace exists. The list is
// therefore derived from the client set and never from an enumeration of
// workspaces — enumerating workspaces would reproduce exactly the blindness this
// exists to compensate for.
//
// Rows are flat and unadorned by decision (see the change
// `add-all-windows-picker`): no grouping, no reachability markers. Left-click
// goes to the window, right-click drags it to the current workspace.

type WinItem = {
  address: string
  title: string
  iconName: string
  workspaceId: number
  // Special workspaces (`special:*`, negative id) are not somewhere you can
  // navigate to — `dispatch workspace special:minimized` flashes the overlay
  // rather than "activating" the window — so go-to degrades to bring-here.
  isSpecial: boolean
}

// AstalHyprland's get_address() returns the address WITHOUT the `0x` prefix
// (e.g. "61fed…"), but `dispatch … address:<addr>` requires the `0x` form or it
// fails with "No such window found". Normalize to `0x…`.
function withHexPrefix(addr: string): string {
  return addr.startsWith("0x") ? addr : `0x${addr}`
}

function getWindows(hyprland: Hyprland.Hyprland): WinItem[] {
  return hyprland.get_clients().map((c) => {
    const ws = c.get_workspace()
    const wsId = ws?.get_id() ?? 0
    const wsName = ws?.get_name() ?? ""
    return {
      address: withHexPrefix(c.get_address()),
      title: c.get_title() || c.get_class() || "window",
      iconName: lookupIcon(c.get_class() || "") || "application-x-executable",
      workspaceId: wsId,
      isSpecial: wsId < 0 || wsName.startsWith("special:"),
    }
  })
}

export default function AllWindows() {
  const hyprland = Hyprland.get_default()
  const [items, setItems] = createState<WinItem[]>(getWindows(hyprland))

  const refresh = () => setItems(getWindows(hyprland))

  // Same signals Minimized.tsx / Workspaces.tsx listen to, so the list tracks
  // windows opening, closing and moving without polling.
  hyprland.connect("client-added", refresh)
  hyprland.connect("client-removed", refresh)
  hyprland.connect("client-moved", refresh)
  hyprland.connect("notify::workspaces", refresh)

  // Captured so an activated row can dismiss the popover itself rather than
  // relying on focus-loss autohide (the actions move focus to another window).
  let popover: Gtk.Popover | null = null

  // Right-click: haul the window to the current workspace. This is the recovery
  // path when the window's own workspace is bound to a monitor that is not
  // connected, where going to it accomplishes nothing.
  const bringHere = (item: WinItem) => {
    const wsId = hyprland.get_focused_workspace()?.get_id()
    if (wsId === undefined) return
    hyprland.dispatch("movetoworkspace", `${wsId},address:${item.address}`)
    hyprland.dispatch("focuswindow", `address:${item.address}`)
    popover?.popdown()
    refresh()
  }

  // Left-click: go to the window, leaving it where it is.
  //
  // `workspace` then `focuswindow` rather than `focuswindow` alone: focuswindow
  // is expected to cross workspaces by itself, but that was not verified (it
  // would have moved focus on a live session), and the two-step is correct
  // either way.
  const goTo = (item: WinItem) => {
    if (item.isSpecial) return bringHere(item)
    hyprland.dispatch("workspace", String(item.workspaceId))
    hyprland.dispatch("focuswindow", `address:${item.address}`)
    popover?.popdown()
    refresh()
  }

  return (
    <menubutton
      class="StatusIcon AllWindows"
      tooltipText={items((list) => `${list.length} windows`)}
    >
      <label class="AllWindowsIcon" label="󱂬" />
      <popover $={(self: Gtk.Popover) => (popover = self)}>
        <box orientation={Gtk.Orientation.VERTICAL} class="AllWindowsPopover">
          <For each={items}>
            {(item: WinItem) => {
              // A Gtk.Button's own click handling is primary-only, so onClicked
              // never fires for a right-click; the secondary gesture is the sole
              // handler for it. Same pattern as the Workspaces screen picker.
              const secondary = new Gtk.GestureClick()
              secondary.set_button(Gdk.BUTTON_SECONDARY)

              return (
                <button
                  class="AllWindowsRow"
                  onClicked={() => goTo(item)}
                  $={(self: Gtk.Widget) => {
                    secondary.connect("pressed", () => bringHere(item))
                    self.add_controller(secondary)
                  }}
                >
                  <box>
                    <image iconName={item.iconName} />
                    <label
                      label={item.title}
                      hexpand
                      halign={Gtk.Align.START}
                      maxWidthChars={48}
                      ellipsize={Pango.EllipsizeMode.END}
                    />
                  </box>
                </button>
              )
            }}
          </For>
        </box>
      </popover>
    </menubutton>
  )
}
