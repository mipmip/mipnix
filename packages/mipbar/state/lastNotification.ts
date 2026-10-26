import Gio from "gi://Gio"
import GLib from "gi://GLib"
import { createState } from "ags"
import { subprocess } from "ags/process"
import {
  parseCache,
  parseNotifyLine,
  serializeNotification,
  type LastNotification,
} from "./notification"

const CACHE_DIR = `${GLib.get_user_cache_dir()}/mipbar`
const CACHE_FILE = `${CACHE_DIR}/last-notification.json`
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

function readCache(): LastNotification | null {
  const content = readText(CACHE_FILE)
  return content === null ? null : parseCache(content)
}

function writeCache(notification: LastNotification | null): void {
  try {
    GLib.mkdir_with_parents(CACHE_DIR, 0o700)
    const target = Gio.File.new_for_path(CACHE_FILE)

    if (notification === null) {
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
      new TextEncoder().encode(serializeNotification(notification)),
      null,
    )
    stream.close(null)
    temporary.move(target, Gio.FileCopyFlags.OVERWRITE, null, null)
  } catch (error) {
    console.error(`mipbar: could not write ${CACHE_FILE}: ${error}`)
  }
}

export function lastCapturePath(): string {
  return readText(LAST_CAPTURE)?.trim() ?? ""
}

export const [lastNotification, setLastNotification] =
  createState<LastNotification | null>(readCache())

export function clearLastNotification(): void {
  setLastNotification(null)
  writeCache(null)
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
        if (notification === null) return
        setLastNotification(notification)
        writeCache(notification)
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
