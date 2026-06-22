// Monitor → accent colour + device/port classification helpers for the
// workspace screen-binding feature. Pure functions, no GTK/AGS imports, so they
// stay testable and deterministic across mipbar reloads.

import Hyprland from "gi://AstalHyprland"

// --- User accent config map -------------------------------------------------
// Stable colour per known monitor name. Unmapped monitors fall back to a
// deterministic palette pick (see monitorAccent). Light-mode hex values; the
// dark variant is derived by brightening (see toDark).
//
// These are this machine's real displays, given well-separated hues so the
// underlines are easy to tell apart at a glance.
export const MONITOR_ACCENTS: Record<string, string> = {
  "eDP-1": "#3aa6a0", // Framework 13 (laptop) — teal
  "DP-2": "#d6457a",  // LG UltraFine (external) — magenta
}

// Curated, well-separated palette for unmapped monitors. Picked by hash so a
// given monitor name is stable across reloads, but spaced far enough apart in
// hue that two unmapped displays don't collide into near-identical colours
// (the raw `hash % 360` approach did exactly that for DP-2 vs eDP-1).
const FALLBACK_PALETTE = [
  "#4874d8", // blue
  "#ea952d", // amber
  "#9b59d0", // purple
  "#e0533b", // red-orange
  "#2bb673", // green
  "#c94f9c", // pink
  "#d8b13a", // gold
  "#3aa6a0", // teal
]

// --- Hashing ---------------------------------------------------------------
// djb2 — deterministic across reloads (no Math.random / Date).
function hash(str: string): number {
  let h = 5381
  for (let i = 0; i < str.length; i++) {
    h = ((h << 5) + h + str.charCodeAt(i)) >>> 0
  }
  return h
}

// --- Colour conversion -----------------------------------------------------
function clamp01(n: number): number {
  return Math.min(1, Math.max(0, n))
}

function hex2(n: number): string {
  const s = Math.round(clamp01(n) * 255).toString(16)
  return s.length === 1 ? "0" + s : s
}

// HSL → hex. Hue 0-360, sat/light 0-1.
function hslToHex(hDeg: number, s: number, l: number): string {
  const h = ((hDeg % 360) + 360) % 360 / 360
  const q = l < 0.5 ? l * (1 + s) : l + s - l * s
  const p = 2 * l - q
  const hue2rgb = (t: number): number => {
    if (t < 0) t += 1
    if (t > 1) t -= 1
    if (t < 1 / 6) return p + (q - p) * 6 * t
    if (t < 1 / 2) return q
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6
    return p
  }
  const r = s === 0 ? l : hue2rgb(h + 1 / 3)
  const g = s === 0 ? l : hue2rgb(h)
  const b = s === 0 ? l : hue2rgb(h - 1 / 3)
  return `#${hex2(r)}${hex2(g)}${hex2(b)}`
}

// Parse #rrggbb → {r,g,b} in 0-1.
function parseHex(hex: string): { r: number; g: number; b: number } {
  const m = hex.replace("#", "")
  return {
    r: parseInt(m.slice(0, 2), 16) / 255,
    g: parseInt(m.slice(2, 4), 16) / 255,
    b: parseInt(m.slice(4, 6), 16) / 255,
  }
}

function rgbToHsl(r: number, g: number, b: number): [number, number, number] {
  const max = Math.max(r, g, b)
  const min = Math.min(r, g, b)
  const l = (max + min) / 2
  let h = 0
  let s = 0
  if (max !== min) {
    const d = max - min
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
    if (max === r) h = (g - b) / d + (g < b ? 6 : 0)
    else if (max === g) h = (b - r) / d + 2
    else h = (r - g) / d + 4
    h *= 60
  }
  return [h, s, l]
}

// Dark-mode variant: same hue/sat, lightness +0.09 (briefing: brighter for
// dark backgrounds). Works for both mapped hex and hashed accents.
function toDark(lightHex: string): string {
  const { r, g, b } = parseHex(lightHex)
  const [h, s, l] = rgbToHsl(r, g, b)
  return hslToHex(h, s, clamp01(l + 0.09))
}

// --- Public API ------------------------------------------------------------

// Deterministic accent for a monitor name. Config map first, then a name-hash
// hue at fixed sat/light. Returns a #rrggbb string.
export function monitorAccent(name: string, isDark: boolean): string {
  const light =
    MONITOR_ACCENTS[name] ?? FALLBACK_PALETTE[hash(name) % FALLBACK_PALETTE.length]
  return isDark ? toDark(light) : light
}

// eDP*/LVDS* are internal panels → laptop; everything else is an external monitor.
export function deviceType(name: string): "laptop" | "monitor" {
  return /^(eDP|LVDS)/i.test(name) ? "laptop" : "monitor"
}

// Best-effort port classification from the connector prefix. USB-C in DP
// alt-mode also enumerates as DP-N, so DP is reported as DisplayPort.
export function portType(name: string): "internal" | "HDMI" | "DisplayPort" | "unknown" {
  if (/^eDP/i.test(name)) return "internal"
  if (/^HDMI/i.test(name)) return "HDMI"
  if (/^DP/i.test(name)) return "DisplayPort"
  return "unknown"
}

// Short label for the port chip.
export function portLabel(name: string): string {
  switch (portType(name)) {
    case "internal": return "Internal"
    case "HDMI": return "HDMI"
    case "DisplayPort": return "DisplayPort"
    default: return "Display"
  }
}

// --- Soft fills (briefing alpha steps) -------------------------------------
// GTK CSS lacks oklch alpha mixing; emit rgba() from the resolved hex.
function rgba(hex: string, alpha: number): string {
  const { r, g, b } = parseHex(hex)
  return `rgba(${Math.round(r * 255)}, ${Math.round(g * 255)}, ${Math.round(b * 255)}, ${alpha})`
}

// Chips / "CURRENT" pill background: 15% light, 26% dark.
export function softFill(accentHex: string, isDark: boolean): string {
  return rgba(accentHex, isDark ? 0.26 : 0.15)
}

// Selected (current-monitor) tile background: 12% light, 22% dark.
export function selectedTileFill(accentHex: string, isDark: boolean): string {
  return rgba(accentHex, isDark ? 0.22 : 0.12)
}

// --- Spec line -------------------------------------------------------------
// `SIZE · RES · REFRESH`, e.g. `27" · 3840×2160 · 60 Hz`. Size is unknown from
// Hyprland (no physical dimensions), so it is omitted unless derivable.
export function specLine(m: Hyprland.Monitor): string {
  const res = `${m.get_width()}×${m.get_height()}`
  const hz = `${Math.round(m.get_refresh_rate())} Hz`
  return `${res} · ${hz}`
}
