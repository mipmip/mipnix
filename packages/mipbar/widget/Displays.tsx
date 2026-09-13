import Gtk from "gi://Gtk?version=4.0"
import Gdk from "gi://Gdk?version=4.0"
import Pango from "gi://Pango"
import GLib from "gi://GLib"
import { createState, For } from "ags"
import { exec, execAsync } from "ags/process"
import { monitorAccent, deviceType, portLabel, softFill, selectedTileFill } from "./monitors"
import {
  parseMonitors,
  parseModes,
  nativeMode,
  snapScale,
  monitorKeyword,
  repackKeyword,
  byPosition,
  formatMode,
  formatRefresh,
  formatScale,
  specLine,
  scaleLine,
  stateLine,
  type DisplayInfo,
  type DisplayMode,
} from "./displayInfo"

// Displays menu — what monitors are attached, and what resolution each runs at.
//
// Runtime only. Nothing here writes Hyprland configuration: `monitors.conf` is a
// read-only Nix store symlink and stays the single source of truth for what a
// monitor does at login. A resolution change is a temporary act (a presentation,
// a recording), and "Reset to configured" is the return trip. This matches the
// precedent already set by ScreenPicker's live workspace rebinding.
//
// The card layout here is deliberately NOT shared with ScreenPicker.tsx. That
// widget holds reactive Hyprland.Monitor GObjects; this one holds plain objects
// parsed from `hyprctl`, rebuilt wholesale on every read. Unifying them would
// mean an adapter layer or a union type threaded through every accessor, to
// spare duplicating layout the two are free to evolve apart. The accent, port
// and device-type helpers in monitors.ts are pure, and those ARE shared.

function isDark(): boolean {
  try {
    return exec("gsettings get org.gnome.desktop.interface color-scheme").includes(
      "prefer-dark",
    )
  } catch {
    return true
  }
}

// Read monitor state from Hyprland.
//
// Synchronous by choice: this runs when the popover opens and after an apply,
// never on a timer, and `hyprctl` returns in single-digit milliseconds. The same
// idiom ScreenPicker uses for its gsettings read.
function readMonitors(): DisplayInfo[] {
  try {
    return parseMonitors(exec(["hyprctl", "monitors", "all", "-j"]))
  } catch {
    return []
  }
}

// --- Device imagery ---------------------------------------------------------
// Parallel to ScreenPicker's, but keyed off DisplayInfo instead of a GObject.

function rgba(hex: string): Gdk.RGBA {
  const c = new Gdk.RGBA()
  c.parse(hex)
  return c
}

function darken(hex: string, amount: number): string {
  const m = hex.replace("#", "")
  const ch = (i: number) =>
    Math.round(parseInt(m.slice(i, i + 2), 16) * (1 - amount))
      .toString(16)
      .padStart(2, "0")
  return `#${ch(0)}${ch(2)}${ch(4)}`
}

function screenTint(name: string, accent: string): string {
  if (/^eDP/i.test(name)) return "#0d401e"
  if (/^DP/i.test(name)) return "#20335e"
  if (/^HDMI/i.test(name)) return "#502b00"
  return darken(accent, 0.55)
}

// Bundled product image for a known display, or null. Connector name first
// (laptop panels report a useless raw model like "0x408D"), then EDID substrings.
function deviceAsset(m: DisplayInfo): string | null {
  const id = `${m.make} ${m.model} ${m.description}`.toUpperCase()
  if (m.name === "eDP-1") return "framework-13"
  if (/ULTRAFINE/.test(id)) return "lg-ultrafine"
  return null
}

function photoImage(m: DisplayInfo): Gtk.Widget | null {
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

function deviceImage(m: DisplayInfo, accentHex: string): Gtk.Widget {
  const photo = photoImage(m)
  if (photo) return photo

  const kind = deviceType(m.name)
  const bezel = rgba("#23262c")
  const stand = rgba("#3a3d44")
  const screen = rgba(screenTint(m.name, accentHex))
  const glow = rgba(accentHex)

  const area = new Gtk.DrawingArea()
  area.set_content_width(58)
  area.set_content_height(42)

  const roundRect = (cr: any, x: number, y: number, w: number, h: number, r: number) => {
    cr.newSubPath()
    cr.arc(x + w - r, y + r, r, -Math.PI / 2, 0)
    cr.arc(x + w - r, y + h - r, r, 0, Math.PI / 2)
    cr.arc(x + r, y + h - r, r, Math.PI / 2, Math.PI)
    cr.arc(x + r, y + r, r, Math.PI, 1.5 * Math.PI)
    cr.closePath()
  }
  const setSrc = (cr: any, c: Gdk.RGBA) => cr.setSourceRGBA(c.red, c.green, c.blue, c.alpha)

  area.set_draw_func((_a: Gtk.DrawingArea, cr: any, w: number, h: number) => {
    if (kind === "monitor") {
      setSrc(cr, stand)
      cr.rectangle(w / 2 - 2, h - 10, 4, 6)
      cr.fill()
      roundRect(cr, w / 2 - 9, h - 5, 18, 4, 2)
      cr.fill()
      setSrc(cr, bezel)
      roundRect(cr, 4, 2, w - 8, h - 14, 4)
      cr.fill()
      setSrc(cr, screen)
      roundRect(cr, 7, 5, w - 14, h - 20, 2)
      cr.fill()
      setSrc(cr, glow)
      roundRect(cr, 9, h - 17, w - 18, 2.5, 1)
      cr.fill()
    } else {
      setSrc(cr, bezel)
      roundRect(cr, 6, 2, w - 12, h - 16, 4)
      cr.fill()
      setSrc(cr, screen)
      roundRect(cr, 9, 5, w - 18, h - 22, 2)
      cr.fill()
      setSrc(cr, glow)
      roundRect(cr, 11, h - 19, w - 22, 2.5, 1)
      cr.fill()
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

// Inline CSS provider for a dynamic colour. GTK CSS cannot take a runtime value,
// and the accent is per monitor, so each coloured widget carries its own provider
// — the same approach ScreenPicker uses.
function tint(widget: Gtk.Widget, css: string): void {
  const provider = new Gtk.CssProvider()
  provider.load_from_string(css)
  widget.get_style_context().add_provider(provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
}

function cssTag(name: string): string {
  return name.replace(/[^a-zA-Z0-9]/g, "_")
}

export default function Displays() {
  const [monitors, setMonitors] = createState<DisplayInfo[]>(readMonitors())

  // Re-read from Hyprland. Called when the popover opens and after every action.
  //
  // Hyprland emits no event for a mode change (verified: a socat listener across
  // one captured nothing while a control `hyprctl reload` produced
  // `configreloaded>>`), so there is nothing to subscribe to. Worse, it can apply
  // a different scale than the one requested and still report `ok`. Re-reading is
  // therefore the only way the card can be trusted — the menu shows what IS, never
  // what was asked for.
  const refresh = () => setMonitors(readMonitors())

  const run = (args: string[]) =>
    execAsync(args)
      .then(() => refresh())
      .catch(() => refresh())

  const applyMode = (m: DisplayInfo, mode: DisplayMode) =>
    run(["hyprctl", "keyword", "monitor", monitorKeyword(m, mode)])

  // Back to monitors.conf. No shadow state, no undo stack — the declarative
  // config is already the truth and `hyprctl reload` re-reads it.
  const resetToConfigured = () => run(["hyprctl", "reload"])

  // Close the positional gap a shrunk monitor leaves behind. Applied in
  // ascending-x order so Hyprland's `auto` lays them out in the order they
  // currently sit, rather than by enumeration order.
  const repackLayout = () => {
    const ordered = [...monitors.get()].sort(byPosition)
    const chain = ordered.reduce(
      (prev, m) =>
        prev.then(() =>
          execAsync(["hyprctl", "keyword", "monitor", repackKeyword(m)]).then(() => {}),
        ),
      Promise.resolve(),
    )
    chain.then(() => refresh()).catch(() => refresh())
  }

  return (
    <menubutton
      class="StatusIcon Displays"
      tooltipText={monitors((list) =>
        list.length === 1 ? "1 display" : `${list.length} displays`,
      )}
    >
      <label class="DisplaysIcon" label="󰍹" />
      <popover
        $={(self: Gtk.Popover) => {
          // The only refresh trigger that matters: the user is about to look.
          self.connect("notify::visible", () => {
            if (self.get_visible()) refresh()
          })
        }}
      >
        <box orientation={Gtk.Orientation.VERTICAL} class="DisplaysPopover">
          <box class="DisplaysHeader">
            <label label="DISPLAYS" hexpand halign={Gtk.Align.START} />
            <button class="ActionSmall" onClicked={resetToConfigured}>
              <label label="⟳ Reset to configured" />
            </button>
          </box>

          <For each={monitors}>
            {(m: DisplayInfo) => {
              const dark = isDark()
              const accent = monitorAccent(m.name, dark)
              const tag = `d-${cssTag(m.name)}`
              const modes = parseModes(m.availableModes)
              const native = nativeMode(modes)

              return (
                <box
                  orientation={Gtk.Orientation.VERTICAL}
                  class={`DisplayCard ${tag}${m.focused ? " focused" : ""}`}
                  $={(self: Gtk.Widget) =>
                    tint(
                      self,
                      `.DisplayCard.${tag} {
                         border-color: ${accent};
                         background: ${m.focused ? selectedTileFill(accent, dark) : "unset"};
                       }`,
                    )
                  }
                >
                  <box class="DisplayHead">
                    <box
                      $={(self: Gtk.Box) => self.append(deviceImage(m, accent))}
                    />
                    <box orientation={Gtk.Orientation.VERTICAL} hexpand>
                      <box>
                        <label
                          class="DisplayModel"
                          label={m.description || m.model || m.name}
                          halign={Gtk.Align.START}
                          hexpand
                          maxWidthChars={34}
                          ellipsize={Pango.EllipsizeMode.END}
                        />
                        {m.focused && (
                          <label
                            class="FocusedPill"
                            label="FOCUSED"
                            $={(self: Gtk.Widget) =>
                              tint(
                                self,
                                `.FocusedPill { color: ${accent}; background: ${softFill(accent, dark)}; }`,
                              )
                            }
                          />
                        )}
                      </box>
                      <label class="DisplaySpec" label={specLine(m)} halign={Gtk.Align.START} />
                      <box class="DisplayMeta">
                        <label
                          class="PortChip"
                          label={portLabel(m.name)}
                          $={(self: Gtk.Widget) =>
                            tint(
                              self,
                              `.PortChip { color: ${accent}; background: ${softFill(accent, dark)}; }`,
                            )
                          }
                        />
                        <label class="ConnectorTag" label={m.name} halign={Gtk.Align.START} />
                        <label
                          class="DisplayPos"
                          label={`ws ${m.activeWorkspaceName || m.activeWorkspaceId} · at ${m.x},${m.y}`}
                          halign={Gtk.Align.START}
                        />
                      </box>
                      <label class="DisplayScale" label={scaleLine(m)} halign={Gtk.Align.START} />
                      <label class="DisplayState" label={stateLine(m)} halign={Gtk.Align.START} />
                    </box>
                  </box>

                  <label
                    class="ResolutionHeader"
                    label="RESOLUTION"
                    halign={Gtk.Align.START}
                  />

                  <box orientation={Gtk.Orientation.VERTICAL} class="ResolutionList">
                    {modes.map((mode) => {
                      const current = mode.width === m.width && mode.height === m.height
                      const isNative =
                        native !== null &&
                        native.width === mode.width &&
                        native.height === mode.height
                      // Predicted BEFORE the click: Hyprland would apply this
                      // silently and report success either way.
                      const snapped = snapScale(mode.width, mode.height, m.scale)

                      return (
                        <button
                          class={`ResolutionRow${current ? " current" : ""}`}
                          onClicked={() => applyMode(m, mode)}
                        >
                          <box>
                            <label
                              class="ResolutionMark"
                              label={current ? "●" : "○"}
                              $={(self: Gtk.Widget) =>
                                current ? tint(self, `.ResolutionMark { color: ${accent}; }`) : undefined
                              }
                            />
                            <label
                              class="ResolutionLabel"
                              label={formatMode(mode)}
                              halign={Gtk.Align.START}
                            />
                            <label
                              class="ResolutionRate"
                              label={formatRefresh(mode.refresh)}
                              halign={Gtk.Align.START}
                              hexpand
                            />
                            {isNative && <label class="NativeTag" label="native" />}
                            {snapped !== null && (
                              <label
                                class="ScaleWarn"
                                label={`⚠ scale → ${formatScale(snapped)}`}
                                halign={Gtk.Align.END}
                              />
                            )}
                          </box>
                        </button>
                      )
                    })}
                  </box>
                </box>
              )
            }}
          </For>

          <box class="DisplaysFooter">
            <button class="ActionSmall" hexpand onClicked={repackLayout}>
              <label label="Re-pack layout" />
            </button>
          </box>
        </box>
      </popover>
    </menubutton>
  )
}
