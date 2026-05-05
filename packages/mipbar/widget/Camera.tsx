import { execAsync } from "ags/process"
import { createPoll } from "ags/time"

function normalizeName(raw: string): string {
  const basename = raw.split("/").pop() || "Unknown"
  return basename.replace(/^\./, "").replace(/-wrapped$/, "")
}

export default function Camera() {
  // Returns "pid:name" or "" if no camera active
  const cameraInfo = createPoll("", 5000, ["bash", "-c",
    `pid=$(lsof -t /dev/video* 2>/dev/null | head -1)
     if [ -n "$pid" ]; then
       cmd=$(cat /proc/$pid/cmdline 2>/dev/null | tr '\\0' ' ' | cut -d' ' -f1)
       echo "$pid:$cmd"
     fi`
  ])

  return (
    <box
      visible={cameraInfo((s) => s.trim() !== "")}
      class="StatusIcon Camera"
      tooltipText={cameraInfo((s) => {
        if (!s.trim()) return "Camera in use"
        const name = normalizeName(s.split(":").slice(1).join(":"))
        return name ? `Camera: ${name}` : "Camera in use"
      })}
    >
      <button
        onClicked={() => {
          const info = cameraInfo.get()
          const pid = info.split(":")[0]
          if (pid) {
            execAsync(`hyprctl dispatch focuswindow pid:${pid}`)
          }
        }}
      >
        <image iconName="camera-web-symbolic" />
      </button>
    </box>
  )
}
