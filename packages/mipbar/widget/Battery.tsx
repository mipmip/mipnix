import AstalBattery from "gi://AstalBattery"
import { createBinding } from "ags"

export default function Battery() {
  const battery = AstalBattery.get_default()

  const percent = createBinding(battery, "percentage")(
    (p) => `${Math.floor(p * 100)}%`,
  )

  return (
    <box visible={createBinding(battery, "isPresent")} class="StatusIcon">
      <image iconName={createBinding(battery, "iconName")} />
      <label label={percent} />
    </box>
  )
}
