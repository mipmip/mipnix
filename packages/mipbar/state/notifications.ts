import Gio from "gi://Gio"
import GLib from "gi://GLib"
import { createState } from "ags"
import { subprocess } from "ags/process"
import {
  MAX_NOTIFICATIONS,
  parseCache,
  parseNotifyLine,
  parseNotifyReply,
  serializeNotifications,
  type NotificationRecord,
  type NotifyReply,
} from "./notification"

const CACHE_DIR = `${GLib.get_user_cache_dir()}/mipbar`
const CACHE_FILE = `${CACHE_DIR}/notifications.json`
const LEGACY_CACHE_FILE = `${CACHE_DIR}/last-notification.json`
const LAST_CAPTURE = `${GLib.get_user_cache_dir()}/hyprshot/last`
const HYPR_SCRIPTS = `${GLib.get_user_config_dir()}/hypr/scripts`

export const SHOT_REVEAL = `${HYPR_SCRIPTS}/shot-reveal-last`
export const SHOT_ANNOTATE = `${HYPR_SCRIPTS}/shot-annotate`
const CAPTURE_COMMAND = [
  "busctl",
  "--user",
  "monitor",
  "org.freedesktop.Notifications",
  "--json=short",
]
const RESTART_DELAY = 5000

function readText(path: string): string | null {
  try {
    const [ok, bytes] = GLib.file_get_contents(path)
    if (!ok) return null
    return new TextDecoder().decode(bytes)
  } catch {
    return null
  }
}

function writeCache(notifications: NotificationRecord[]): void {
  try {
    GLib.mkdir_with_parents(CACHE_DIR, 0o700)
    const target = Gio.File.new_for_path(CACHE_FILE)

    if (notifications.length === 0) {
      if (target.query_exists(null)) target.delete(null)
      return
    }

    const temporary = Gio.File.new_for_path(`${CACHE_FILE}.tmp`)
    const stream = temporary.replace(
      null,
      false,
      Gio.FileCreateFlags.PRIVATE,
      null,
    )
    stream.write_all(
      new TextEncoder().encode(serializeNotifications(notifications)),
      null,
    )
    stream.close(null)
    temporary.move(target, Gio.FileCopyFlags.OVERWRITE, null, null)
  } catch (error) {
    console.error(`mipbar: could not write ${CACHE_FILE}: ${error}`)
  }
}

function readCache(): NotificationRecord[] {
  const current = readText(CACHE_FILE)
  if (current !== null) return parseCache(current)

  const legacy = readText(LEGACY_CACHE_FILE)
  if (legacy === null) return []

  const migrated = parseCache(legacy)
  writeCache(migrated)

  try {
    const file = Gio.File.new_for_path(LEGACY_CACHE_FILE)
    if (file.query_exists(null)) file.delete(null)
  } catch {}

  return migrated
}

export function lastCapturePath(): string {
  return readText(LAST_CAPTURE)?.trim() ?? ""
}

export const [notifications, setNotifications] = createState<
  NotificationRecord[]
>(readCache())

const pending = new Map<string, string>()

function publish(list: NotificationRecord[]): void {
  const capped = list.slice(0, MAX_NOTIFICATIONS)
  setNotifications(capped)
  writeCache(capped)
}

function add(record: NotificationRecord): void {
  const current = notifications.get()
  const kept =
    record.id > 0 ? current.filter((item) => item.id !== record.id) : current
  publish([record, ...kept])

  if (record.id === 0) {
    pending.set(`${record.caller}:${record.cookie}`, record.key)
  }
}

function assignId(reply: NotifyReply): void {
  const pendingKey = `${reply.caller}:${reply.cookie}`
  const key = pending.get(pendingKey)
  if (key === undefined) return

  pending.delete(pendingKey)
  const current = notifications.get()
  if (!current.some((item) => item.key === key)) return

  publish(
    current.map((item) => (item.key === key ? { ...item, id: reply.id } : item)),
  )
}

export function clearNotifications(): void {
  pending.clear()
  publish([])
}

let monitor: ReturnType<typeof subprocess> | null = null
let restart: number | null = null
let running = false

function scheduleStart(): void {
  if (!running || restart !== null) return
  restart = setTimeout(() => {
    restart = null
    startNotificationCapture()
  }, RESTART_DELAY)
}

export function startNotificationCapture(): void {
  if (monitor !== null) return
  running = true

  try {
    const process = subprocess(
      CAPTURE_COMMAND,
      (line) => {
        const notification = parseNotifyLine(line)
        if (notification !== null) {
          add(notification)
          return
        }

        const reply = parseNotifyReply(line)
        if (reply !== null) assignId(reply)
      },
      (line) => console.error(`mipbar: notification capture: ${line}`),
    )

    monitor = process
    process.connect("exit", () => {
      monitor = null
      scheduleStart()
    })
  } catch (error) {
    console.error(`mipbar: could not start notification capture: ${error}`)
    scheduleStart()
  }
}

export function stopNotificationCapture(): void {
  running = false
  if (restart !== null) {
    clearTimeout(restart)
    restart = null
  }
  if (monitor !== null) {
    const process = monitor
    monitor = null
    process.kill()
  }
}
