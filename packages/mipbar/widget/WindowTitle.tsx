import Hyprland from "gi://AstalHyprland"
import Pango from "gi://Pango"
import { Gtk } from "ags/gtk4"
import { createBinding, With } from "ags"
import { lookupIcon } from "./utils"

export default function WindowTitle() {
  const hyprland = Hyprland.get_default()
  const focusedClient = createBinding(hyprland, "focusedClient")

  return (
    <box class="WindowTitle" visible={focusedClient(Boolean)}>
      <With value={focusedClient}>
        {(client) => client && (
          <box>
            <image
              class="WindowTitleIcon"
              iconName={createBinding(client, "class")((c) => lookupIcon(c || "") || "application-x-executable")}
            />
            <label
              class="WindowTitleLabel"
              label={createBinding(client, "title")((t) => t || "")}
              ellipsize={Pango.EllipsizeMode.END}
              maxWidthChars={60}
            />
          </box>
        )}
      </With>
    </box>
  )
}
