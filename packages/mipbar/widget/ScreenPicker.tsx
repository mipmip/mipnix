import Hyprland from "gi://AstalHyprland"
import Gtk from "gi://Gtk?version=4.0"
import Gdk from "gi://Gdk?version=4.0"
import Pango from "gi://Pango"
import GLib from "gi://GLib"
import { exec } from "ags/process"
import {
  monitorAccent,
  deviceType,
  portLabel,
  softFill,
  selectedTileFill,
  specLine,
} from "./monitors"

function isDark(): boolean {
  try {
    return exec("gsettings get org.gnome.desktop.interface color-scheme").includes("prefer-dark")
  } catch {
    return true
  }
}

// Parse "#rrggbb" → Gdk.RGBA for cairo drawing.
function rgba(hex: string): Gdk.RGBA {
  const c = new Gdk.RGBA()
  c.parse(hex)
  return c
}

// Darken a hex toward black by `amount` (0..1). Used for the screen tint when
// no per-port tint is configured.
function darken(hex: string, amount: number): string {
  const m = hex.replace("#", "")
  const ch = (i: number) =>
    Math.round(parseInt(m.slice(i, i + 2), 16) * (1 - amount))
      .toString(16)
      .padStart(2, "0")
  return `#${ch(0)}${ch(2)}${ch(4)}`
}

// Per-port screen tint (briefing); falls back to a darkened accent.
function screenTint(name: string, accent: string): string {
  if (/^eDP/i.test(name)) return "#0d401e"
  if (/^DP/i.test(name)) return "#20335e"
  if (/^HDMI/i.test(name)) return "#502b00"
  return darken(accent, 0.55)
}

// --- Device product images --------------------------------------------------
// Map a monitor to a bundled product image (rasterized from assets/*.svg at
// build time → assets/<name>.png). Connector name is the primary key (laptop
// panels report a useless raw model like "0x095F"); make/model substrings are a
// secondary path. Returns the asset basename (without extension) or null.
//
// To add a real product photo later: drop assets/<basename>.png (overriding the
// generated illustration) and add a match clause here.
function deviceAsset(m: Hyprland.Monitor): string | null {
  const name = m.get_name()
  const id = `${m.get_make() ?? ""} ${m.get_model() ?? ""} ${m.get_description() ?? ""}`.toUpperCase()

  // This machine's known displays.
  if (name === "eDP-1") return "framework-13" // BOE 0x095F internal panel = Framework 13
  if (/ULTRAFINE/.test(id)) return "lg-ultrafine"
  return null
}

// Load the bundled PNG for a monitor, or null if there is no match / no file.
function photoImage(m: Hyprland.Monitor): Gtk.Widget | null {
  const asset = deviceAsset(m)
  if (!asset) return null
  const path = `${SRC}/assets/${asset}.png`
  if (!GLib.file_test(path, GLib.FileTest.EXISTS)) return null
  const img = new Gtk.Image({ file: path })
  img.set_pixel_size(42)
  img.set_size_request(58, 42)
  img.add_css_class("DeviceImage")
  return img
}

// --- Device illustration ----------------------------------------------------
// A small (~58×42px) stylised drawing tinted by the monitor accent. Two
// variants keyed off deviceType. Used as the fallback when no product image
// matches (see photoImage / deviceAsset).
function deviceImage(m: Hyprland.Monitor, accentHex: string): Gtk.Widget {
  // Prefer a real bundled product image; fall back to the drawn illustration.
  const photo = photoImage(m)
  if (photo) return photo

  const name = m.get_name()
  const kind = deviceType(name)
  const bezel = rgba("#23262c")
  const stand = rgba("#3a3d44")
  const screen = rgba(screenTint(name, accentHex))
  const glow = rgba(accentHex)

  const area = new Gtk.DrawingArea()
  area.set_content_width(58)
  area.set_content_height(42)

  const roundRect = (
    cr: any,
    x: number,
    y: number,
    w: number,
    h: number,
    r: number,
  ) => {
    cr.newSubPath()
    cr.arc(x + w - r, y + r, r, -Math.PI / 2, 0)
    cr.arc(x + w - r, y + h - r, r, 0, Math.PI / 2)
    cr.arc(x + r, y + h - r, r, Math.PI / 2, Math.PI)
    cr.arc(x + r, y + r, r, Math.PI, 1.5 * Math.PI)
    cr.closePath()
  }

  const setSrc = (cr: any, c: Gdk.RGBA) =>
    cr.setSourceRGBA(c.red, c.green, c.blue, c.alpha)

  area.set_draw_func((_a: Gtk.DrawingArea, cr: any, w: number, h: number) => {
    if (kind === "monitor") {
      // Stand (neck + base)
      setSrc(cr, stand)
      cr.rectangle(w / 2 - 2, h - 10, 4, 6)
      cr.fill()
      roundRect(cr, w / 2 - 9, h - 5, 18, 4, 2)
      cr.fill()
      // Bezel
      setSrc(cr, bezel)
      roundRect(cr, 4, 2, w - 8, h - 14, 4)
      cr.fill()
      // Screen
      setSrc(cr, screen)
      roundRect(cr, 7, 5, w - 14, h - 20, 2)
      cr.fill()
      // Glow line along the screen bottom
      setSrc(cr, glow)
      roundRect(cr, 9, h - 17, w - 18, 2.5, 1)
      cr.fill()
    } else {
      // Laptop: lid (bezel+screen+glow) + trapezoidal keyboard base
      setSrc(cr, bezel)
      roundRect(cr, 6, 2, w - 12, h - 16, 4)
      cr.fill()
      setSrc(cr, screen)
      roundRect(cr, 9, 5, w - 18, h - 22, 2)
      cr.fill()
      setSrc(cr, glow)
      roundRect(cr, 11, h - 19, w - 22, 2.5, 1)
      cr.fill()
      // Trapezoidal base
      setSrc(cr, stand)
      cr.moveTo(2, h - 3)
      cr.lineTo(w - 2, h - 3)
      cr.lineTo(w - 8, h - 9)
      cr.lineTo(8, h - 9)
      cr.closePath()
      cr.fill()
    }
  })

  return area
}

// --- One monitor row --------------------------------------------------------
function monitorRow(
  hyprland: Hyprland.Hyprland,
  m: Hyprland.Monitor,
  workspaceId: number,
  isCurrent: boolean,
  dark: boolean,
  popover: Gtk.Popover,
): Gtk.Widget {
  const name = m.get_name()
  const accent = monitorAccent(name, dark)

  const row = new Gtk.Button()
  row.add_css_class("ScreenRow")
  if (isCurrent) row.add_css_class("current")
  // Per-row accent fed via inline CSS provider (accent is dynamic per monitor).
  const css = new Gtk.CssProvider()
  css.load_from_string(`
    .ScreenRow.r-${workspaceId}-${name.replace(/[^a-zA-Z0-9]/g, "_")} {
      border-color: ${accent};
      background: ${isCurrent ? selectedTileFill(accent, dark) : "unset"};
    }
  `)
  const tag = `r-${workspaceId}-${name.replace(/[^a-zA-Z0-9]/g, "_")}`
  row.add_css_class(tag)
  row.get_style_context().add_provider(css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

  const hbox = new Gtk.Box({
    orientation: Gtk.Orientation.HORIZONTAL,
    spacing: 12,
  })

  hbox.append(deviceImage(m, accent))

  const col = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 4 })

  // Line 1: model + optional CURRENT pill
  const line1 = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 6 })
  const model = new Gtk.Label({
    label: m.get_description() || m.get_model() || name,
    halign: Gtk.Align.START,
    ellipsize: Pango.EllipsizeMode.END,
  })
  model.add_css_class("ScreenModel")
  line1.append(model)
  if (isCurrent) {
    const pill = new Gtk.Label({ label: "CURRENT" })
    pill.add_css_class("CurrentPill")
    const pillCss = new Gtk.CssProvider()
    pillCss.load_from_string(`.CurrentPill { color: ${accent}; background: ${softFill(accent, dark)}; }`)
    pill.get_style_context().add_provider(pillCss, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
    line1.append(pill)
  }
  col.append(line1)

  // Line 2: spec line
  const spec = new Gtk.Label({ label: specLine(m), halign: Gtk.Align.START })
  spec.add_css_class("ScreenSpec")
  col.append(spec)

  // Line 3: port chip + connector tag
  const line3 = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 8 })
  const chip = new Gtk.Label({ label: portLabel(name) })
  chip.add_css_class("PortChip")
  const chipCss = new Gtk.CssProvider()
  chipCss.load_from_string(`.PortChip { color: ${accent}; background: ${softFill(accent, dark)}; }`)
  chip.get_style_context().add_provider(chipCss, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
  line3.append(chip)
  const connector = new Gtk.Label({ label: name, halign: Gtk.Align.START })
  connector.add_css_class("ConnectorTag")
  line3.append(connector)
  col.append(line3)

  hbox.append(col)
  row.set_child(hbox)

  row.connect("clicked", () => {
    // Live rebind only — no persistent Hyprland config written.
    hyprland.dispatch("moveworkspacetomonitor", `${workspaceId} ${name}`)
    popover.popdown()
  })

  return row
}

// Build + present the screen picker popover anchored to `button` for `workspaceId`.
export function openScreenPicker(
  hyprland: Hyprland.Hyprland,
  button: Gtk.Widget,
  workspaceId: number,
): void {
  const dark = isDark()
  const monitors = hyprland.get_monitors()

  // Current monitor for this workspace (if the workspace exists).
  const ws = hyprland.get_workspaces().find((w) => w.get_id() === workspaceId)
  const currentName = ws?.get_monitor()?.get_name() ?? null

  const popover = new Gtk.Popover()
  popover.add_css_class("ScreenPicker")
  popover.set_parent(button)
  popover.set_position(Gtk.PositionType.BOTTOM)

  const container = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 0 })

  const header = new Gtk.Label({
    label: `WORKSPACE ${workspaceId} · BOUND TO SCREEN`,
    halign: Gtk.Align.START,
  })
  header.add_css_class("ScreenPickerHeader")
  container.append(header)

  for (const m of monitors) {
    container.append(
      monitorRow(hyprland, m, workspaceId, m.get_name() === currentName, dark, popover),
    )
  }

  popover.set_child(container)
  // Clean up the popover widget once dismissed so we don't leak a parent ref.
  popover.connect("closed", () => popover.unparent())
  popover.popup()
}
