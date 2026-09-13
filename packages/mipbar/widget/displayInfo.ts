// Display enumeration + geometry maths for the Displays menu.
//
// Named displayInfo.ts, not displays.ts: a lowercase `displays.ts` collides
// case-insensitively with Displays.tsx, and esbuild resolves `./displays` to
// the widget — dragging GTK into a headless test run.
//
// Pure functions and plain data only — no GTK/AGS imports — in the style of
// monitors.ts, so the arithmetic here (mode deduplication, scale snapping,
// density) stays testable and deterministic across mipbar reloads.
//
// The data source is `hyprctl monitors all -j`, NOT AstalHyprland. Two reasons,
// both measured during the spike for `add-mipbar-displays-menu`:
//
//  1. AstalHyprland.Monitor has no physical-dimension property. `hyprctl`
//     reports physicalWidth/physicalHeight in millimetres, which is what turns
//     a bare resolution into a diagonal and a DPI figure — the difference
//     between informing the user and restating numbers they already knew.
//
//  2. Hyprland emits NO event for a mode/scale/position change. A socat
//     listener on .socket2.sock across a resolution change captured nothing,
//     while a control `hyprctl reload` in the same window produced
//     `configreloaded>>`. AstalHyprland refreshes its monitor objects from that
//     socket, so after an applied change its objects are stale permanently.

// --- Types ------------------------------------------------------------------

export type DisplayMode = {
  width: number
  height: number
  refresh: number
}

export type DisplayInfo = {
  id: number
  name: string
  description: string
  make: string
  model: string
  serial: string
  width: number
  height: number
  refreshRate: number
  x: number
  y: number
  scale: number
  transform: number
  focused: boolean
  dpmsStatus: boolean
  vrr: boolean
  disabled: boolean
  mirrorOf: string
  activeWorkspaceId: number
  activeWorkspaceName: string
  physicalWidth: number
  physicalHeight: number
  availableModes: string[]
}

// --- Parsing ----------------------------------------------------------------

function num(v: unknown, fallback = 0): number {
  return typeof v === "number" && isFinite(v) ? v : fallback
}

function str(v: unknown, fallback = ""): string {
  return typeof v === "string" ? v : fallback
}

// Parse the output of `hyprctl monitors all -j`. Tolerant of missing fields:
// Hyprland's monitor JSON has grown keys over releases, and a field this widget
// merely displays must never be able to blank the whole menu.
export function parseMonitors(json: string): DisplayInfo[] {
  let raw: unknown
  try {
    raw = JSON.parse(json)
  } catch {
    return []
  }
  if (!Array.isArray(raw)) return []

  return raw.map((r: any): DisplayInfo => {
    const ws = r?.activeWorkspace ?? {}
    return {
      id: num(r?.id, -1),
      name: str(r?.name),
      description: str(r?.description),
      make: str(r?.make),
      model: str(r?.model),
      serial: str(r?.serial),
      width: num(r?.width),
      height: num(r?.height),
      refreshRate: num(r?.refreshRate),
      x: num(r?.x),
      y: num(r?.y),
      // A zero scale would divide by zero everywhere downstream.
      scale: num(r?.scale, 1) || 1,
      transform: num(r?.transform),
      focused: r?.focused === true,
      dpmsStatus: r?.dpmsStatus === true,
      vrr: r?.vrr === true,
      disabled: r?.disabled === true,
      mirrorOf: str(r?.mirrorOf, "none"),
      activeWorkspaceId: num(ws?.id, -1),
      activeWorkspaceName: str(ws?.name),
      physicalWidth: num(r?.physicalWidth),
      physicalHeight: num(r?.physicalHeight),
      availableModes: Array.isArray(r?.availableModes)
        ? r.availableModes.filter((m: unknown) => typeof m === "string")
        : [],
    }
  })
}

// --- Modes ------------------------------------------------------------------

// Parse one `availableModes` entry, e.g. "1920x1080@60.05Hz".
export function parseMode(s: string): DisplayMode | null {
  const m = /^(\d+)x(\d+)@([\d.]+)Hz$/.exec(s.trim())
  if (!m) return null
  const width = parseInt(m[1], 10)
  const height = parseInt(m[2], 10)
  const refresh = parseFloat(m[3])
  if (!width || !height || !isFinite(refresh)) return null
  return { width, height, refresh }
}

// Deduplicate `availableModes` down to one entry per resolution, keeping the
// highest refresh rate, sorted by pixel count descending.
//
// Refresh rate is deliberately not a user choice here (see the change's
// design.md): a monitor offering 3840x2160@60 and @30 presents ONE row, and
// selecting it applies 60. Nobody picks the slower of two identical-resolution
// modes on purpose.
export function parseModes(availableModes: string[]): DisplayMode[] {
  const best = new Map<string, DisplayMode>()
  for (const s of availableModes) {
    const mode = parseMode(s)
    if (!mode) continue
    const key = `${mode.width}x${mode.height}`
    const prev = best.get(key)
    if (!prev || mode.refresh > prev.refresh) best.set(key, mode)
  }
  return [...best.values()].sort(
    (a, b) => b.width * b.height - a.width * a.height,
  )
}

// The native (preferred) mode: the largest available resolution. Hyprland tends
// to list the preferred mode first, but ordering is not contractual, so pick by
// pixel count instead of trusting position.
export function nativeMode(modes: DisplayMode[]): DisplayMode | null {
  return modes.length > 0 ? modes[0] : null
}

export function sameResolution(a: DisplayMode, w: number, h: number): boolean {
  return a.width === w && a.height === h
}

// --- Scale ------------------------------------------------------------------

// Hyprland quantises scale to 1/120 and requires the resulting logical size to
// be whole pixels.
const SCALE_QUANTUM = 120
const EPSILON = 0.001

function isWhole(n: number): boolean {
  return Math.abs(Math.round(n) - n) < EPSILON
}

// Does this resolution produce a whole-pixel logical size at `scale`?
export function scaleFits(width: number, height: number, scale: number): boolean {
  if (scale <= 0) return false
  return isWhole(width / scale) && isWhole(height / scale)
}

// The scale Hyprland will actually use for `width`x`height` if `scale` does not
// divide evenly.
//
// Returns null when the requested scale fits — i.e. null means "no surprise".
//
// This mirrors Hyprland's own search: quantise the requested scale to 1/120,
// then walk outwards one quantum at a time, testing the UP candidate before the
// DOWN candidate, and take the first that yields a whole-pixel logical size.
//
// Verified against the spike: 1280x1024 at scale 1.5 is reported by Hyprland as
// `ok` and silently becomes scale 1.6 (1280/1.6 = 800, 1024/1.6 = 640 exactly),
// which is what this returns. Predicting it lets the menu warn BEFORE the click
// rather than leaving the user to notice their desktop resized.
export function snapScale(
  width: number,
  height: number,
  scale: number,
): number | null {
  if (scaleFits(width, height, scale)) return null

  const search = Math.round(scale * SCALE_QUANTUM)
  for (let i = 1; i < 90; i++) {
    const up = (search + i) / SCALE_QUANTUM
    if (scaleFits(width, height, up)) return up
    const down = (search - i) / SCALE_QUANTUM
    if (down > 0 && scaleFits(width, height, down)) return down
  }
  return null
}

// --- Derived geometry -------------------------------------------------------

export function logicalSize(
  width: number,
  height: number,
  scale: number,
): { width: number; height: number } {
  if (scale <= 0) return { width, height }
  return { width: width / scale, height: height / scale }
}

// Physical diagonal in inches from the EDID millimetre dimensions. Null when the
// panel reports no physical size (common for projectors and some KVMs).
export function diagonalInches(
  physicalWidth: number,
  physicalHeight: number,
): number | null {
  if (physicalWidth <= 0 || physicalHeight <= 0) return null
  const mm = Math.hypot(physicalWidth, physicalHeight)
  return mm / 25.4
}

// Native and effective pixel density. Both are rotation-invariant: each divides
// a pixel diagonal by a physical diagonal, so a 90° transform does not skew them.
export function density(
  width: number,
  height: number,
  diagonalIn: number | null,
  scale: number,
): { native: number; effective: number } | null {
  if (!diagonalIn || diagonalIn <= 0 || scale <= 0) return null
  const native = Math.hypot(width, height) / diagonalIn
  return { native, effective: native / scale }
}

// --- Presentation helpers ---------------------------------------------------

export function formatMode(mode: DisplayMode): string {
  return `${mode.width}×${mode.height}`
}

export function formatRefresh(hz: number): string {
  return `${Math.round(hz)} Hz`
}

export function formatScale(scale: number): string {
  return scale.toFixed(2)
}

export function formatDiagonal(diagonalIn: number | null): string | null {
  return diagonalIn ? `${diagonalIn.toFixed(1)}″` : null
}

// `transform` is Hyprland's enum: 0-3 are 0/90/180/270°, 4-7 are the same with a
// flip. Only reported when non-default, so the card stays quiet in the normal case.
export function transformLabel(transform: number): string | null {
  if (transform === 0) return null
  const deg = [0, 90, 180, 270][transform % 4]
  return transform >= 4 ? `flipped ${deg}°` : `${deg}°`
}

export function mirrorLabel(mirrorOf: string): string | null {
  return !mirrorOf || mirrorOf === "none" ? null : `mirroring ${mirrorOf}`
}

// --- Card lines -------------------------------------------------------------
// The three strings the menu actually renders. Pure, so the text the user reads
// is covered by the headless tests rather than only by looking at the bar.

// `13.9″ · 1920×1080 · 60 Hz`.
//
// Unlike monitors.ts's specLine, the SIZE field is genuinely populated here:
// hyprctl reports physical millimetres, which AstalHyprland does not expose. It
// is omitted (rather than faked) when the panel reports no physical size.
export function specLine(m: DisplayInfo): string {
  const parts: string[] = []
  const diag = formatDiagonal(diagonalInches(m.physicalWidth, m.physicalHeight))
  if (diag) parts.push(diag)
  parts.push(`${m.width}×${m.height}`)
  parts.push(formatRefresh(m.refreshRate))
  return parts.join(" · ")
}

// `scale 1.50 → 1280×720 · 158/106 dpi`
export function scaleLine(m: DisplayInfo): string {
  const logical = logicalSize(m.width, m.height, m.scale)
  const parts = [
    `scale ${formatScale(m.scale)} → ${Math.round(logical.width)}×${Math.round(logical.height)}`,
  ]
  const d = density(
    m.width,
    m.height,
    diagonalInches(m.physicalWidth, m.physicalHeight),
    m.scale,
  )
  if (d) parts.push(`${Math.round(d.native)}/${Math.round(d.effective)} dpi`)
  return parts.join(" · ")
}

// Trailing state line. Rotation and mirroring appear ONLY when non-default, so
// the common case stays quiet instead of padding every card with "0°, no mirror".
export function stateLine(m: DisplayInfo): string {
  const parts: string[] = []
  const rotation = transformLabel(m.transform)
  if (rotation) parts.push(rotation)
  const mirror = mirrorLabel(m.mirrorOf)
  if (mirror) parts.push(mirror)
  parts.push(m.vrr ? "vrr on" : "vrr off")
  parts.push(m.dpmsStatus ? "dpms on" : "dpms off")
  if (m.disabled) parts.push("disabled")
  return parts.join(" · ")
}

// The `hyprctl keyword monitor` argument applying `mode` to `m`.
//
// Position and scale are passed through from the monitor's CURRENT state rather
// than given as `auto`. The spike showed why: `auto` position relocated a
// monitor from 2560x0 to 0x0, and `auto` scale chose 1.6 for 1280x720 (an
// 800x450 logical desktop). Both are startling as a side effect of "change the
// resolution". Re-packing positions is available, but only as a deliberate act.
export function monitorKeyword(m: DisplayInfo, mode: DisplayMode): string {
  return [
    m.name,
    `${mode.width}x${mode.height}@${mode.refresh.toFixed(2)}`,
    `${m.x}x${m.y}`,
    String(m.scale),
  ].join(",")
}

// Same, but with `auto` position — the Re-pack layout action. Applying these in
// ascending-x order makes Hyprland lay the monitors out left to right with no
// gaps, closing the dead region a shrunk monitor leaves behind.
export function repackKeyword(m: DisplayInfo): string {
  return [
    m.name,
    `${m.width}x${m.height}@${m.refreshRate.toFixed(2)}`,
    "auto",
    String(m.scale),
  ].join(",")
}

export function byPosition(a: DisplayInfo, b: DisplayInfo): number {
  return a.x - b.x || a.y - b.y
}
