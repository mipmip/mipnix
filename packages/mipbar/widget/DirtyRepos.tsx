import Gtk from "gi://Gtk?version=4.0"
import GLib from "gi://GLib"
import Pango from "gi://Pango"
import { createState, For } from "ags"
import { execAsync } from "ags/process"
import { interval } from "ags/time"
import { parseDrs, tooltipText, displayName, shortPath, type DirtyRepo, type DirtyState } from "./dirtyRepoStatus"

const HOUR = 60 * 60 * 1000

export default function DirtyRepos() {
  const home = GLib.get_home_dir()
  const [state, setState] = createState<DirtyState>({ repos: [], scannedAt: null, failed: false })
  let inFlight = false

  const scan = () => {
    if (inFlight) return
    inFlight = true
    execAsync(["drs", "--json"])
      .then((out) => setState({ repos: parseDrs(out), scannedAt: new Date(), failed: false }))
      .catch(() => setState({ ...state.get(), failed: true }))
      .finally(() => {
        inFlight = false
      })
  }

  interval(HOUR, scan)

  const repos = state((s) => s.repos)

  return (
    <menubutton
      class="StatusIcon BarIcon DirtyRepos"
      visible={state((s) => s.repos.length > 0)}
      tooltipText={state(tooltipText)}
    >
      <box>
        <label class="DirtyReposIcon" label="󰊢" />
        <label class="DirtyReposCount" label={state((s) => String(s.repos.length))} />
      </box>
      <popover
        $={(self: Gtk.Popover) => {
          self.connect("notify::visible", () => {
            if (self.get_visible()) scan()
          })
        }}
      >
        <box orientation={Gtk.Orientation.VERTICAL} class="DirtyReposPopover">
          <For each={repos}>
            {(repo: DirtyRepo) => (
              <box orientation={Gtk.Orientation.VERTICAL} class="DirtyReposRow">
                <label
                  class="DirtyReposName"
                  label={displayName(repo.path)}
                  halign={Gtk.Align.START}
                />
                <label
                  class="DirtyReposPath"
                  label={shortPath(repo.path, home)}
                  halign={Gtk.Align.START}
                  maxWidthChars={48}
                  ellipsize={Pango.EllipsizeMode.MIDDLE}
                />
              </box>
            )}
          </For>
        </box>
      </popover>
    </menubutton>
  )
}
