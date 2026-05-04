import Hyprland from "gi://AstalHyprland"
import { createState } from "ags"

export default function Screenshare() {
  const hyprland = Hyprland.get_default()
  const [active, setActive] = createState(false)

  hyprland.connect("event", (_: any, event: string, args: string) => {
    if (event === "screencast") {
      const [state] = args.split(",")
      setActive(state === "1")
    }
  })

  return (
    <box visible={active} class="StatusIcon Screenshare">
      <image iconName="camera-web-symbolic" />
    </box>
  )
}
