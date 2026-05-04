import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { createPoll } from "ags/time"
import Workspaces from "./Workspaces"
import Wifi from "./Wifi"
import Battery from "./Battery"
import Screenshare from "./Screenshare"
import Tray from "./Tray"
import SystemMonitor from "./SystemMonitor"
import WindowTitle from "./WindowTitle"

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const time = createPoll("", 60000, 'bash -c \'LC_TIME=nl_NL.UTF-8 date +"%a %-d %b, %H:%M"\'')
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  return (
    <window
      visible
      name="bar"
      class="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <centerbox cssName="centerbox">
        <box $type="start" halign={Gtk.Align.START}>
          <button
            class="AppLauncher"
            onClicked={() => execAsync("walker")}
          >
            <label label="󱗼" />
          </button>
          <Workspaces />
        </box>
        <box $type="center">
          <WindowTitle />
        </box>
        <box $type="end" halign={Gtk.Align.END}>
          <SystemMonitor />
          <menubutton>
            <label label={time} />
            <popover>
              <Gtk.Calendar />
            </popover>
          </menubutton>
          <Tray />
          <Screenshare />
          <Wifi />
          <Battery />
        </box>
      </centerbox>
    </window>
  )
}
