import { Gtk } from "ags/gtk4"
import { With } from "ags"
import { createPoll } from "ags/time"

// CPU
const cpuText = createPoll("...", 3000, ["bash", "-c",
  "top -bn1 | awk '/^%Cpu/{printf \"%.0f%%\", 100-$8}'"])
const cpuFrac = createPoll(0, 3000, ["bash", "-c",
  "top -bn1 | awk '/^%Cpu/{printf \"%.2f\", (100-$8)/100}'"],
  (s) => parseFloat(s) || 0)

// Memory
const memText = createPoll("...", 5000, ["bash", "-c",
  "free -h | awk '/^Mem:/{printf \"%s / %s\", $3, $2}'"])
const memFrac = createPoll(0, 5000, ["bash", "-c",
  "free | awk '/^Mem:/{printf \"%.2f\", $3/$2}'"],
  (s) => parseFloat(s) || 0)

// Swap
const swapText = createPoll("...", 5000, ["bash", "-c",
  "free -h | awk '/^Swap:/{printf \"%s / %s\", $3, $2}'"])
const swapFrac = createPoll(0, 5000, ["bash", "-c",
  "free | awk '/^Swap:/{if($2>0) printf \"%.2f\", $3/$2; else printf \"0\"}'"],
  (s) => parseFloat(s) || 0)

type DiskInfo = { mount: string; used: string; size: string; frac: number }

// Disks - parsed into structured data
const disks = createPoll([] as DiskInfo[], 60000, ["bash", "-c",
  "df -h --output=target,size,used,pcent -x tmpfs -x devtmpfs -x efivarfs | tail -n+2 | awk '{gsub(/%/,\"\", $4); printf \"%s\\t%s\\t%s\\t%s\\n\", $1, $2, $3, $4}'"],
  (stdout) => {
    return stdout.trim().split("\n").filter(Boolean).map((line) => {
      const [mount, size, used, pct] = line.split("\t")
      return { mount, used, size, frac: (parseInt(pct) || 0) / 100 }
    })
  })

// Network
const network = createPoll("...", 3000, ["bash", "-c",
  `r1=$(cat /proc/net/dev | awk 'NR>2 && !/lo/{r+=$2; t+=$10} END{print r, t}')
   sleep 1
   r2=$(cat /proc/net/dev | awk 'NR>2 && !/lo/{r+=$2; t+=$10} END{print r, t}')
   echo "$r1 $r2" | awk '{
     dr=($3-$1)/1024; dt=($4-$2)/1024
     if(dr>=1024) printf "↓%.0fM ", dr/1024; else printf "↓%.0fK ", dr
     if(dt>=1024) printf "↑%.0fM/s", dt/1024; else printf "↑%.0fK/s", dt
   }'`])

const localIp = createPoll("...", 30000, ["bash", "-c",
  "hostname -I | awk '{print $1}'"])

const externalIp = createPoll("...", 300000, ["bash", "-c",
  "curl -4 -s --max-time 5 ifconfig.me || echo N/A"])

function BarRow({ icon, label, value, fraction }: {
  icon: string; label: string; value: any; fraction: any
}) {
  return (
    <box orientation={Gtk.Orientation.VERTICAL} class="BarRow">
      <box class="BarRowHeader">
        <label class="SensorIcon" label={icon} />
        <label class="SensorLabel" label={label} hexpand halign={Gtk.Align.START} />
        <label class="SensorValue" label={value} halign={Gtk.Align.END} />
      </box>
      <levelbar class="SensorBar" value={fraction} />
    </box>
  )
}

function TextRow({ icon, label, value }: { icon: string; label: string; value: any }) {
  return (
    <box class="SensorRow">
      <label class="SensorIcon" label={icon} />
      <label class="SensorLabel" label={label} hexpand halign={Gtk.Align.START} />
      <label class="SensorValue" label={value} halign={Gtk.Align.END} />
    </box>
  )
}

export default function SystemMonitor() {
  return (
    <menubutton class="SystemMonitor">
      <label class="SystemMonitorIcon" label="󰍛" />
      <popover>
        <box orientation={Gtk.Orientation.VERTICAL} class="MonitorPopover">
          <BarRow icon="󰍛" label="CPU" value={cpuText} fraction={cpuFrac} />
          <BarRow icon="󰘚" label="Memory" value={memText} fraction={memFrac} />
          <BarRow icon="󰾴" label="Swap" value={swapText} fraction={swapFrac} />
          <box orientation={Gtk.Orientation.VERTICAL} class="DiskSection">
            <With value={disks}>
              {(ds) => (
                <box orientation={Gtk.Orientation.VERTICAL}>
                  {ds.map((d) => (
                    <box orientation={Gtk.Orientation.VERTICAL} class="BarRow">
                      <box class="BarRowHeader">
                        <label class="SensorIcon" label="󰋊" />
                        <label class="SensorLabel" label={d.mount} hexpand halign={Gtk.Align.START} />
                        <label class="SensorValue" label={`${d.used} / ${d.size}`} halign={Gtk.Align.END} />
                      </box>
                      <levelbar class="SensorBar" value={d.frac} />
                    </box>
                  ))}
                </box>
              )}
            </With>
          </box>
          <TextRow icon="󰛳" label="Network" value={network} />
          <TextRow icon="󰩟" label="Local IP" value={localIp} />
          <TextRow icon="󰩠" label="External IP" value={externalIp} />
        </box>
      </popover>
    </menubutton>
  )
}
