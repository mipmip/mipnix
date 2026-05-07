import Hyprland from "gi://AstalHyprland"
import { Gtk } from "ags/gtk4"
import { createBinding, createState, For } from "ags"
import { lookupIcon } from "./utils"
import { execAsync } from "ags/process"

type ClientInfo = {
  class: string
  title: string
  iconName: string
}

type WorkspaceItem = {
  id: number
  isGroupStart: boolean
  isLaptop: boolean
  clients: ClientInfo[]
}

const WORKSPACE_IDS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
const LAPTOP_IDS = new Set([8, 9, 0])

function getWorkspaceItems(hyprland: Hyprland.Hyprland): WorkspaceItem[] {
  const workspaceMap = new Map<number, Hyprland.Workspace>()
  for (const w of hyprland.get_workspaces()) {
    if (w.id >= 0) workspaceMap.set(w.id, w)
  }

  return WORKSPACE_IDS.map((id, index) => {
    const workspace = workspaceMap.get(id)
    const clients: ClientInfo[] = workspace
      ? workspace.get_clients().map((c) => ({
          class: c.class || "",
          title: c.title || "",
          iconName: lookupIcon(c.class || ""),
        }))
      : []

    // Group separator between workspace 7 and 8
    const isGroupStart = id === 8

    return { id, isGroupStart, isLaptop: LAPTOP_IDS.has(id), clients }
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
              if (item.isLaptop) cls += " laptop"
              if (fw?.id === item.id) cls += " focused"
              return cls
            })}
            onClicked={() => execAsync(`hyprctl dispatch workspace ${item.id}`)}
          >
            <box>
              <label label={String(item.id)} />
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
