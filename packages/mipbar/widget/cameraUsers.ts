export interface CameraUser {
  pid: number | null
  name: string
}

export interface CameraState {
  active: boolean
  users: CameraUser[]
}

const CAMERA_APIS = ["libcamera", "v4l2"]
const MEDIA_SERVERS = ["pipewire", "wireplumber"]

type Props = Record<string, unknown>

interface PwObject {
  id: number
  type: string
  info?: {
    state?: string
    props?: Props
    "output-node-id"?: number
    "input-node-id"?: number
  }
}

export function normalizeName(raw: string): string {
  const basename = raw.split("/").pop() || ""
  return basename.replace(/^\./, "").replace(/-wrapped$/, "")
}

function toPid(value: unknown): number | null {
  const pid = Number(value)
  return Number.isInteger(pid) && pid > 0 ? pid : null
}

function str(value: unknown): string {
  return typeof value === "string" ? value : ""
}

export function isCameraSource(props: Props): boolean {
  return props["media.class"] === "Video/Source" && CAMERA_APIS.includes(str(props["device.api"]))
}

export function parsePwDump(json: string): CameraState {
  let objects: PwObject[]
  try {
    objects = JSON.parse(json)
  } catch {
    return { active: false, users: [] }
  }
  if (!Array.isArray(objects)) return { active: false, users: [] }

  const byId = new Map(objects.map((o) => [o.id, o]))
  const sources = objects.filter(
    (o) => o.type === "PipeWire:Interface:Node" && isCameraSource(o.info?.props ?? {}),
  )
  const sourceIds = new Set(sources.map((s) => s.id))

  const consumerIds = new Set(
    objects
      .filter((o) => o.type === "PipeWire:Interface:Link")
      .filter((l) => sourceIds.has(l.info?.["output-node-id"] ?? -1))
      .map((l) => l.info?.["input-node-id"] ?? -1),
  )

  const users: CameraUser[] = []
  for (const id of consumerIds) {
    const node = byId.get(id)
    if (!node || node.info?.state !== "running") continue
    const nodeProps = node.info?.props ?? {}
    const client = byId.get(Number(nodeProps["client.id"]))
    const clientProps = client?.info?.props ?? {}
    const raw =
      str(clientProps["application.process.binary"]) ||
      str(clientProps["application.name"]) ||
      str(nodeProps["application.name"]) ||
      str(nodeProps["node.name"])
    users.push({
      pid: toPid(clientProps["application.process.id"] ?? nodeProps["application.process.id"]),
      name: normalizeName(raw),
    })
  }

  const sourceRunning = sources.some((s) => s.info?.state === "running")
  return { active: sourceRunning || users.length > 0, users }
}

export function parseLsof(output: string): CameraUser[] {
  const users: CameraUser[] = []
  let pid: number | null = null
  for (const line of output.split("\n")) {
    if (line.startsWith("p")) {
      pid = toPid(line.slice(1))
    } else if (line.startsWith("c") && pid !== null) {
      const command = line.slice(1)
      if (!MEDIA_SERVERS.some((s) => command.startsWith(s))) {
        users.push({ pid, name: normalizeName(command) })
      }
      pid = null
    }
  }
  return users
}

export function mergeUsers(...lists: CameraUser[][]): CameraUser[] {
  const seen = new Set<number>()
  const merged: CameraUser[] = []
  for (const user of lists.flat()) {
    if (user.pid !== null) {
      if (seen.has(user.pid)) continue
      seen.add(user.pid)
    }
    merged.push(user)
  }
  return merged
}

export function focusable(users: CameraUser[]): CameraUser[] {
  return users.filter((u) => u.pid !== null)
}

export function tooltipText(state: CameraState): string {
  const names = state.users.map((u) => u.name).filter((n) => n !== "")
  if (names.length === 0) return "Camera in use"
  return `Camera: ${names.join(", ")}`
}
