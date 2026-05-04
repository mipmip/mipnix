import Hyprland from "gi://AstalHyprland"
import { Gtk } from "ags/gtk4"
import { createBinding, createState, For } from "ags"
import { lookupIcon } from "./utils"

type ClientInfo = {
  class: string
  title: string
  iconName: string
}

type WorkspaceItem = {
  workspace: Hyprland.Workspace
  isGroupStart: boolean
  clients: ClientInfo[]
}

function getWorkspaceItems(hyprland: Hyprland.Hyprland): WorkspaceItem[] {
  const workspaces = hyprland.get_workspaces()
  const occupied = workspaces
    .filter((w) => w.id > 0 && w.get_clients().length > 0)
    .sort((a, b) => {
      const monA = a.monitor?.name ?? ""
      const monB = b.monitor?.name ?? ""
      if (monA !== monB) return monA.localeCompare(monB)
      return a.id - b.id
    })

  let lastMon = ""
  return occupied.map((workspace) => {
    const mon = workspace.monitor?.name ?? ""
    const isGroupStart = mon !== lastMon
    lastMon = mon

    const clients: ClientInfo[] = workspace.get_clients().map((c) => ({
      class: c.class || "",
      title: c.title || "",
      iconName: lookupIcon(c.class || ""),
    }))

    return { workspace, isGroupStart, clients }
  })
}

export default function Workspaces() {
  const hyprland = Hyprland.get_default()
  const focusedWorkspace = createBinding(hyprland, "focusedWorkspace")

  const [items, setItems] = createState<WorkspaceItem[]>(getWorkspaceItems(hyprland))

  const refresh = () => setItems(getWorkspaceItems(hyprland))

  hyprland.connect("notify::workspaces", refresh)
  hyprland.connect("client-added", refresh)
  hyprland.connect("client-removed", refresh)
  hyprland.connect("client-moved", refresh)

  return (
    <box class="Workspaces">
      <For each={items}>
        {(item: WorkspaceItem) => (
          <button
            class={focusedWorkspace((fw) => {
              let cls = "WorkspaceButton"
              if (item.isGroupStart) cls += " group-start"
              if (fw?.id === item.workspace.id) cls += " focused"
              return cls
            })}
            onClicked={() => item.workspace.focus()}
          >
            <box>
              <label label={String(item.workspace.id)} />
              {item.clients.map((client) => (
                <image
                  class="AppIcon"
                  iconName={client.iconName || "application-x-executable"}
                  tooltipText={client.title}
                />
              ))}
            </box>
          </button>
        )}
      </For>
    </box>
  )
}
