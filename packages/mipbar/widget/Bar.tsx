import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { createPoll } from "ags/time"
import Workspaces from "./Workspaces"
import Screenshare from "./Screenshare"
import Camera from "./Camera"
import SshKey from "./SshKey"
import Minimized from "./Minimized"
import AllWindows from "./AllWindows"
import Tray from "./Tray"
import SystemMonitor from "./SystemMonitor"
import WindowTitle from "./WindowTitle"
import QuickSettings from "./QuickSettings"

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const time = createPoll("", 60000, 'bash -c \'LC_TIME=nl_NL.UTF-8 date +"W%V · %a %-d %b · %H:%M"\'')
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  return (
    <window
      visible
      name={`bar-${gdkmonitor.get_connector() || "default"}`}
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
          <Tray />
          <menubutton>
            <label label={time} />
            <popover>
              <Gtk.Calendar />
            </popover>
          </menubutton>
          <Camera />
          <Screenshare />
          <Minimized />
          <AllWindows />
          <SshKey />
          <SystemMonitor />
          <QuickSettings />
        </box>
      </centerbox>
    </window>
  )
}
