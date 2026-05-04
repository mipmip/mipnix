import AstalNetwork from "gi://AstalNetwork"
import AstalBattery from "gi://AstalBattery"
import { createBinding, With } from "ags"
import QuickSettingsPanel from "./QuickSettingsPanel"

export default function QuickSettings() {
  const network = AstalNetwork.get_default()
  const wifi = createBinding(network, "wifi")
  const battery = AstalBattery.get_default()

  const percent = createBinding(battery, "percentage")(
    (p) => `${Math.floor(p * 100)}%`,
  )

  return (
    <menubutton class="QuickSettings">
      <box>
        <box visible={wifi(Boolean)} class="StatusIcon">
          <With value={wifi}>
            {(w) => w && (
              <image iconName={createBinding(w, "iconName")} />
            )}
          </With>
        </box>
        <box visible={createBinding(battery, "isPresent")} class="StatusIcon">
          <image iconName={createBinding(battery, "iconName")} />
          <label label={percent} />
        </box>
      </box>
      <popover>
        <QuickSettingsPanel />
      </popover>
    </menubutton>
  )
}
