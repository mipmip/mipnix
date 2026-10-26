export type NotificationAction = {
  id: string
  label: string
}

export type LastNotification = {
  appName: string
  appIcon: string
  summary: string
  body: string
  image: string
  actions: NotificationAction[]
  receivedAt: number
}

type Hint = {
  data?: unknown
}

function text(value: unknown): string {
  return typeof value === "string" ? value : ""
}

export function isAbsolutePath(value: string): boolean {
  return value.startsWith("/")
}

function hintString(hints: unknown, name: string): string {
  if (hints === null || typeof hints !== "object") return ""
  const hint = (hints as Record<string, unknown>)[name]
  if (hint === null || typeof hint !== "object") return ""
  return text((hint as Hint).data)
}

function parseActions(raw: unknown): NotificationAction[] {
  if (!Array.isArray(raw)) return []
  const actions: NotificationAction[] = []
  for (let index = 0; index + 1 < raw.length; index += 2) {
    const id = text(raw[index])
    if (id === "") continue
    const label = text(raw[index + 1])
    actions.push({ id, label: label === "" ? id : label })
  }
  return actions
}

function actionIds(notification: LastNotification): Set<string> {
  return new Set(notification.actions.map((action) => action.id))
}

export function isScreenshot(notification: LastNotification): boolean {
  const ids = actionIds(notification)
  return ids.has("default") && ids.has("annotate")
}

export function screenshotPath(
  notification: LastNotification,
  fallback: string,
): string {
  return isAbsolutePath(notification.image) ? notification.image : fallback
}

export function themedIcon(notification: LastNotification): string | null {
  if (notification.image !== "" && !isAbsolutePath(notification.image)) {
    return notification.image
  }
  if (notification.appIcon !== "" && !isAbsolutePath(notification.appIcon)) {
    return notification.appIcon
  }
  return null
}

export function parseNotifyLine(
  line: string,
  now: number = Date.now(),
): LastNotification | null {
  if (!line.includes('"member":"Notify"')) return null
  if (!line.includes('"interface":"org.freedesktop.Notifications"')) return null

  let message: unknown
  try {
    message = JSON.parse(line)
  } catch {
    return null
  }
  if (message === null || typeof message !== "object") return null

  const entry = message as Record<string, unknown>
  if (entry.type !== "method_call") return null
  if (entry.member !== "Notify") return null
  if (entry.interface !== "org.freedesktop.Notifications") return null

  const payload = entry.payload
  if (payload === null || typeof payload !== "object") return null
  const data = (payload as { data?: unknown }).data
  if (!Array.isArray(data) || data.length < 8) return null

  const appName = text(data[0])
  const appIcon = text(data[2])
  const summary = text(data[3])
  const body = text(data[4])
  const actions = parseActions(data[5])
  const hints = data[6]

  const image =
    hintString(hints, "image-path") ||
    hintString(hints, "image_path") ||
    (isAbsolutePath(appIcon) ? appIcon : "")

  return {
    appName,
    appIcon,
    summary,
    body,
    image,
    actions,
    receivedAt: now,
  }
}

const ENTITIES: Record<string, string> = {
  amp: "&",
  lt: "<",
  gt: ">",
  quot: '"',
  apos: "'",
  nbsp: "\u00a0",
}

function decodeEntities(value: string): string {
  return value.replace(
    /&(#x?[0-9a-fA-F]+|[a-zA-Z]+);/g,
    (match: string, entity: string) => {
      if (entity.startsWith("#")) {
        const hex = entity[1] === "x" || entity[1] === "X"
        const code = hex
          ? parseInt(entity.slice(2), 16)
          : parseInt(entity.slice(1), 10)
        if (!Number.isFinite(code) || code <= 0 || code > 0x10ffff) return match
        return String.fromCodePoint(code)
      }
      return ENTITIES[entity] ?? match
    },
  )
}

export function plainText(value: string): string {
  return decodeEntities(value.replace(/<[^>]*>/g, "")).trim()
}

export function relativeTime(then: number, now: number = Date.now()): string {
  const seconds = Math.max(0, Math.floor((now - then) / 1000))
  if (seconds < 60) return "zojuist"
  const minutes = Math.floor(seconds / 60)
  if (minutes < 60) return `${minutes} min geleden`
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `${hours} uur geleden`
  const days = Math.floor(hours / 24)
  return days === 1 ? "1 dag geleden" : `${days} dagen geleden`
}

export function serializeNotification(notification: LastNotification): string {
  return JSON.stringify(notification)
}

function isAction(value: unknown): value is NotificationAction {
  if (value === null || typeof value !== "object") return false
  const action = value as Record<string, unknown>
  return typeof action.id === "string" && typeof action.label === "string"
}

export function isLastNotification(value: unknown): value is LastNotification {
  if (value === null || typeof value !== "object") return false
  const notification = value as Record<string, unknown>
  return (
    typeof notification.appName === "string" &&
    typeof notification.appIcon === "string" &&
    typeof notification.summary === "string" &&
    typeof notification.body === "string" &&
    typeof notification.image === "string" &&
    Array.isArray(notification.actions) &&
    notification.actions.every(isAction) &&
    typeof notification.receivedAt === "number" &&
    Number.isFinite(notification.receivedAt)
  )
}

export function parseCache(value: string): LastNotification | null {
  let parsed: unknown
  try {
    parsed = JSON.parse(value)
  } catch {
    return null
  }
  if (!isLastNotification(parsed)) return null

  return {
    appName: parsed.appName,
    appIcon: parsed.appIcon,
    summary: parsed.summary,
    body: parsed.body,
    image: parsed.image,
    actions: parsed.actions.map((action) => ({
      id: action.id,
      label: action.label,
    })),
    receivedAt: parsed.receivedAt,
  }
}
