export type NotificationAction = {
  id: string
  label: string
}

export type NotificationRecord = {
  key: string
  id: number
  caller: string
  cookie: number
  appName: string
  appIcon: string
  summary: string
  body: string
  image: string
  actions: NotificationAction[]
  receivedAt: number
}

export type NotifyReply = {
  caller: string
  cookie: number
  id: number
}

export const MAX_NOTIFICATIONS = 50

type Hint = {
  data?: unknown
}

function text(value: unknown): string {
  return typeof value === "string" ? value : ""
}

function count(value: unknown, fallback: number): number {
  return typeof value === "number" && Number.isFinite(value) ? value : fallback
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

function actionIds(notification: NotificationRecord): Set<string> {
  return new Set(notification.actions.map((action) => action.id))
}

export function isScreenshot(notification: NotificationRecord): boolean {
  const ids = actionIds(notification)
  return ids.has("default") && ids.has("annotate")
}

export function screenshotPath(
  notification: NotificationRecord,
  fallback: string,
): string {
  return isAbsolutePath(notification.image) ? notification.image : fallback
}

export function themedIcon(notification: NotificationRecord): string | null {
  if (notification.image !== "" && !isAbsolutePath(notification.image)) {
    return notification.image
  }
  if (notification.appIcon !== "" && !isAbsolutePath(notification.appIcon)) {
    return notification.appIcon
  }
  return null
}

function payloadData(message: Record<string, unknown>): unknown[] | null {
  const payload = message.payload
  if (payload === null || typeof payload !== "object") return null
  const data = (payload as { data?: unknown }).data
  return Array.isArray(data) ? data : null
}

export function parseNotifyLine(
  line: string,
  now: number = Date.now(),
): NotificationRecord | null {
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

  const data = payloadData(entry)
  if (data === null || data.length < 8) return null

  const caller = text(entry.sender)
  const cookie = count(entry.cookie, 0)
  const replacesId = count(data[1], 0)
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
    key: `${caller}:${cookie}:${now}`,
    id: replacesId,
    caller,
    cookie,
    appName,
    appIcon,
    summary,
    body,
    image,
    actions,
    receivedAt: now,
  }
}

export function parseNotifyReply(line: string): NotifyReply | null {
  if (!line.includes('"reply_cookie"')) return null

  let message: unknown
  try {
    message = JSON.parse(line)
  } catch {
    return null
  }
  if (message === null || typeof message !== "object") return null

  const entry = message as Record<string, unknown>
  if (entry.type !== "method_return") return null

  const cookie = entry.reply_cookie
  if (typeof cookie !== "number" || !Number.isFinite(cookie)) return null

  const data = payloadData(entry)
  if (data === null || data.length === 0) return null
  const id = data[0]
  if (typeof id !== "number" || !Number.isInteger(id) || id < 0) return null

  return {
    caller: text(entry.destination),
    cookie,
    id,
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

export function serializeNotifications(
  notifications: NotificationRecord[],
): string {
  return JSON.stringify(notifications)
}

function isAction(value: unknown): value is NotificationAction {
  if (value === null || typeof value !== "object") return false
  const action = value as Record<string, unknown>
  return typeof action.id === "string" && typeof action.label === "string"
}

function isStoredNotification(
  value: unknown,
): value is Record<string, unknown> & {
  appName: string
  appIcon: string
  summary: string
  body: string
  image: string
  actions: NotificationAction[]
  receivedAt: number
} {
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

function toRecord(
  notification: Record<string, unknown> & {
    appName: string
    appIcon: string
    summary: string
    body: string
    image: string
    actions: NotificationAction[]
    receivedAt: number
  },
  index: number,
): NotificationRecord {
  const receivedAt = notification.receivedAt
  return {
    key:
      typeof notification.key === "string" && notification.key !== ""
        ? notification.key
        : `${receivedAt}-${index}`,
    id: count(notification.id, 0),
    caller:
      typeof notification.caller === "string" ? notification.caller : "",
    cookie: count(notification.cookie, 0),
    appName: notification.appName,
    appIcon: notification.appIcon,
    summary: notification.summary,
    body: notification.body,
    image: notification.image,
    actions: notification.actions.map((action) => ({
      id: action.id,
      label: action.label,
    })),
    receivedAt,
  }
}

export function parseCache(value: string): NotificationRecord[] {
  let parsed: unknown
  try {
    parsed = JSON.parse(value)
  } catch {
    return []
  }

  const entries = Array.isArray(parsed) ? parsed : [parsed]
  const notifications: NotificationRecord[] = []

  for (let index = 0; index < entries.length; index++) {
    const entry = entries[index]
    if (!isStoredNotification(entry)) continue
    notifications.push(toRecord(entry, index))
    if (notifications.length >= MAX_NOTIFICATIONS) break
  }

  return notifications
}
