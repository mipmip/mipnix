import { Gtk } from "ags/gtk4"
import { createBinding, With } from "ags"
import { execAsync } from "ags/process"
import { createState } from "ags"
import AstalNetwork from "gi://AstalNetwork"
import AstalWp from "gi://AstalWp"
import AstalBluetooth from "gi://AstalBluetooth"

function ToggleRow() {
  const network = AstalNetwork.get_default()
  const wifi = createBinding(network, "wifi")
  const bt = AstalBluetooth.get_default()
  const [airplaneOn, setAirplaneOn] = createState(false)

  // Read initial airplane mode state
  execAsync("bash -c \"rfkill list | grep -c 'Soft blocked: yes'\"")
    .then((out) => setAirplaneOn(parseInt(out.trim()) > 0))
    .catch(() => {})

  return (
    <box class="ToggleRow" homogeneous>
      <With value={wifi}>
        {(w) => w && (
          <togglebutton
            class="Toggle"
            active={createBinding(w, "enabled")}
            onToggled={(self) => { w.enabled = self.active }}
          >
            <box orientation={Gtk.Orientation.VERTICAL}>
              <image iconName="network-wireless-symbolic" />
              <label label="WiFi" />
            </box>
          </togglebutton>
        )}
      </With>
      <togglebutton
        class="Toggle"
        active={createBinding(bt, "isPowered")}
        onToggled={() => {
          const adapter = bt.adapter
          if (adapter) adapter.powered = !adapter.powered
        }}
      >
        <box orientation={Gtk.Orientation.VERTICAL}>
          <image iconName="bluetooth-symbolic" />
          <label label="BT" />
        </box>
      </togglebutton>
      <togglebutton
        class="Toggle"
        active={airplaneOn}
        onToggled={() => {
          const newState = !airplaneOn.get()
          execAsync(newState ? "rfkill block all" : "rfkill unblock all")
            .then(() => setAirplaneOn(newState))
            .catch(() => {})
        }}
      >
        <box orientation={Gtk.Orientation.VERTICAL}>
          <image iconName="airplane-mode-symbolic" />
          <label label="Airplane" />
        </box>
      </togglebutton>
    </box>
  )
}

function VolumeSliders() {
  const wp = AstalWp.get_default()

  return (
    <box orientation={Gtk.Orientation.VERTICAL} class="VolumeSliders">
      <With value={createBinding(wp!, "defaultSpeaker")}>
        {(speaker) => speaker && (
          <box class="VolumeRow">
            <image iconName={createBinding(speaker, "volumeIcon")} />
            <slider
              hexpand
              value={createBinding(speaker, "volume")}
              onChangeValue={(self) => { speaker.volume = self.value }}
            />
          </box>
        )}
      </With>
      <With value={createBinding(wp!, "defaultMicrophone")}>
        {(mic) => mic && (
          <box class="VolumeRow">
            <image iconName={createBinding(mic, "volumeIcon")} />
            <slider
              hexpand
              value={createBinding(mic, "volume")}
              onChangeValue={(self) => { mic.volume = self.value }}
            />
          </box>
        )}
      </With>
    </box>
  )
}

function WifiStatus() {
  const network = AstalNetwork.get_default()
  const wifi = createBinding(network, "wifi")

  return (
    <With value={wifi}>
      {(w) => w && (
        <box class="StatusRow">
          <image iconName="network-wireless-symbolic" />
          <label label={createBinding(w, "ssid")((s) => s || "Not connected")} hexpand halign={Gtk.Align.START} />
          <button
            class="ActionSmall"
            onClicked={() => execAsync("ghostty -e nmtui")}
          >
            <label label="Manage" />
          </button>
        </box>
      )}
    </With>
  )
}

function BluetoothStatus() {
  const bt = AstalBluetooth.get_default()

  return (
    <box class="StatusRow">
      <image iconName="bluetooth-symbolic" />
      <label
        label={createBinding(bt, "isPowered")((on) => on ? "Bluetooth: On" : "Bluetooth: Off")}
        hexpand
        halign={Gtk.Align.START}
      />
      <button
        class="ActionSmall"
        onClicked={() => execAsync("blueman-manager")}
      >
        <label label="Pair" />
      </button>
    </box>
  )
}

function ActionButtons() {
  return (
    <box class="ActionButtons" homogeneous>
      <button
        class="ActionButton"
        onClicked={() => execAsync("hyprlock")}
      >
        <box orientation={Gtk.Orientation.VERTICAL}>
          <image iconName="system-lock-screen-symbolic" />
          <label label="Lock" />
        </box>
      </button>
      <button
        class="ActionButton"
        onClicked={() => execAsync("systemctl suspend")}
      >
        <box orientation={Gtk.Orientation.VERTICAL}>
          <image iconName="system-suspend-symbolic" />
          <label label="Sleep" />
        </box>
      </button>
      <button
        class="ActionButton"
        onClicked={() => execAsync("hyprshot -m region")}
      >
        <box orientation={Gtk.Orientation.VERTICAL}>
          <image iconName="applets-screenshooter-symbolic" />
          <label label="Screen" />
        </box>
      </button>
    </box>
  )
}

export default function QuickSettingsPanel() {
  return (
    <box orientation={Gtk.Orientation.VERTICAL} class="QuickSettingsPanel">
      <ToggleRow />
      <Gtk.Separator />
      <VolumeSliders />
      <Gtk.Separator />
      <WifiStatus />
      <BluetoothStatus />
      <Gtk.Separator />
      <ActionButtons />
    </box>
  )
}
