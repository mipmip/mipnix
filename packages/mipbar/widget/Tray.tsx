import AstalTray from "gi://AstalTray"
import Gtk from "gi://Gtk?version=4.0"
import { createBinding, For } from "ags"

export default function Tray() {
  const tray = AstalTray.get_default()
  const items = createBinding(tray, "items")

  const init = (btn: Gtk.MenuButton, item: AstalTray.TrayItem) => {
    const iconThemePath = item.iconThemePath
    if (iconThemePath) {
      const iconTheme = Gtk.IconTheme.get_for_display(btn.get_display())
      iconTheme.add_search_path(iconThemePath)
    }

    btn.menuModel = item.menuModel
    btn.insert_action_group("dbusmenu", item.actionGroup)

    item.connect("notify::action-group", () => {
      btn.insert_action_group("dbusmenu", item.actionGroup)
    })
    item.connect("notify::menu-model", () => {
      btn.menuModel = item.menuModel
    })
    item.connect("notify::icon-theme-path", () => {
      if (item.iconThemePath) {
        const iconTheme = Gtk.IconTheme.get_for_display(btn.get_display())
        iconTheme.add_search_path(item.iconThemePath)
      }
    })
  }

  return (
    <box class="Tray">
      <For each={items}>
        {(item) => (
          <menubutton
            class="TrayItem"
            tooltipText={createBinding(item, "tooltipText")}
            $={(self) => init(self, item)}
          >
            <image gicon={createBinding(item, "gicon")} />
          </menubutton>
        )}
      </For>
    </box>
  )
}
