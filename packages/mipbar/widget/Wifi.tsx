import AstalNetwork from "gi://AstalNetwork"
import { createBinding, With } from "ags"

export default function Wifi() {
  const network = AstalNetwork.get_default()
  const wifi = createBinding(network, "wifi")

  return (
    <box visible={wifi(Boolean)} class="StatusIcon">
      <With value={wifi}>
        {(w) => w && (
          <image iconName={createBinding(w, "iconName")} />
        )}
      </With>
    </box>
  )
}
