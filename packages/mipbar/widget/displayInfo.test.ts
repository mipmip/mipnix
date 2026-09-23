// Tests for the Displays menu's pure helpers.
//
// Run via `nix build .#checks.<system>.mipbar-displays`, which transpiles this
// with esbuild and executes it on node. displays.ts imports nothing from GTK or
// AGS precisely so this can run headless.
//
// The fixtures are real `hyprctl monitors all -j` output captured during the
// spike, not invented shapes — including the scale-snapping case that motivated
// snapScale() in the first place.

import {
  parseMonitors,
  parseMode,
  parseModes,
  nativeMode,
  scaleFits,
  snapScale,
  logicalSize,
  diagonalInches,
  density,
  transformLabel,
  mirrorLabel,
  monitorKeyword,
  repackKeyword,
  byPosition,
  formatMode,
  formatRefresh,
  formatScale,
  formatDiagonal,
  specLine,
  scaleLine,
  stateLine,
  type DisplayInfo,
} from "./displayInfo"

// --- Tiny harness -----------------------------------------------------------

let checks = 0
let failures = 0

function ok(cond: boolean, label: string): void {
  checks++
  if (!cond) {
    failures++
    console.error(`  FAIL  ${label}`)
  }
}

function eq<T>(actual: T, expected: T, label: string): void {
  checks++
  const a = JSON.stringify(actual)
  const e = JSON.stringify(expected)
  if (a !== e) {
    failures++
    console.error(`  FAIL  ${label}\n          expected ${e}\n          actual   ${a}`)
  }
}

function near(actual: number | null, expected: number, tol: number, label: string): void {
  checks++
  if (actual === null || Math.abs(actual - expected) > tol) {
    failures++
    console.error(`  FAIL  ${label}\n          expected ~${expected} (±${tol})\n          actual   ${actual}`)
  }
}

function group(name: string, body: () => void): void {
  console.log(`- ${name}`)
  body()
}

// --- Fixture: real `hyprctl monitors all -j` from the spike ------------------

const EDP1_JSON = `[{
  "id": 0,
  "name": "eDP-1",
  "description": "AU Optronics 0x408D",
  "make": "AU Optronics",
  "model": "0x408D",
  "serial": "",
  "width": 1920,
  "height": 1080,
  "physicalWidth": 310,
  "physicalHeight": 170,
  "refreshRate": 60.04900,
  "x": 2560,
  "y": 0,
  "activeWorkspace": { "id": 1, "name": "1" },
  "specialWorkspace": { "id": 0, "name": "" },
  "reserved": [0, 37, 0, 0],
  "scale": 1.50,
  "transform": 0,
  "focused": true,
  "dpmsStatus": true,
  "vrr": false,
  "disabled": false,
  "currentFormat": "XRGB8888",
  "mirrorOf": "none",
  "availableModes": ["1920x1080@60.05Hz","1680x1050@60.05Hz","1280x1024@60.05Hz","1440x900@60.05Hz","1280x800@60.05Hz","1280x720@60.05Hz","1024x768@60.05Hz","800x600@60.05Hz","640x480@60.05Hz"]
}]`

const edp1 = parseMonitors(EDP1_JSON)[0]

// --- parseMonitors ----------------------------------------------------------

group("parseMonitors", () => {
  eq(parseMonitors(EDP1_JSON).length, 1, "one monitor parsed")
  eq(edp1.name, "eDP-1", "name")
  eq(edp1.description, "AU Optronics 0x408D", "description")
  eq(edp1.width, 1920, "width")
  eq(edp1.height, 1080, "height")
  eq(edp1.x, 2560, "x")
  eq(edp1.y, 0, "y")
  eq(edp1.scale, 1.5, "scale")
  eq(edp1.focused, true, "focused")
  eq(edp1.vrr, false, "vrr")
  eq(edp1.dpmsStatus, true, "dpmsStatus")
  eq(edp1.mirrorOf, "none", "mirrorOf")
  eq(edp1.activeWorkspaceId, 1, "activeWorkspaceId")
  eq(edp1.physicalWidth, 310, "physicalWidth")
  eq(edp1.physicalHeight, 170, "physicalHeight")
  eq(edp1.availableModes.length, 9, "availableModes")
  near(edp1.refreshRate, 60.049, 0.001, "refreshRate")

  // Robustness: a display the menu can still render is better than a blank menu.
  eq(parseMonitors("not json"), [], "malformed JSON yields no monitors")
  eq(parseMonitors("{}"), [], "non-array JSON yields no monitors")
  eq(parseMonitors("[]"), [], "empty array")

  const sparse = parseMonitors(`[{"name":"DP-9"}]`)[0]
  eq(sparse.name, "DP-9", "sparse monitor keeps its name")
  eq(sparse.scale, 1, "missing scale defaults to 1, never 0")
  eq(sparse.availableModes, [], "missing availableModes defaults to empty")
  eq(sparse.mirrorOf, "none", "missing mirrorOf defaults to none")

  // A zero scale in the JSON would make every derived figure divide by zero.
  eq(parseMonitors(`[{"name":"X","scale":0}]`)[0].scale, 1, "zero scale coerced to 1")

  // availableModes with a non-string member must not poison the list.
  eq(
    parseMonitors(`[{"name":"X","availableModes":["1920x1080@60.00Hz",7,null]}]`)[0]
      .availableModes,
    ["1920x1080@60.00Hz"],
    "non-string modes filtered out",
  )
})

// --- parseMode / parseModes -------------------------------------------------

group("parseMode", () => {
  eq(parseMode("1920x1080@60.05Hz"), { width: 1920, height: 1080, refresh: 60.05 }, "standard")
  eq(parseMode("3840x2160@30.00Hz"), { width: 3840, height: 2160, refresh: 30 }, "4k30")
  eq(parseMode("  1024x768@60.00Hz  "), { width: 1024, height: 768, refresh: 60 }, "whitespace tolerated")
  eq(parseMode("garbage"), null, "garbage rejected")
  eq(parseMode("1920x1080"), null, "missing refresh rejected")
  eq(parseMode("1920x1080@60.05"), null, "missing Hz suffix rejected")
  eq(parseMode("0x0@60.00Hz"), null, "zero dimensions rejected")
})

group("parseModes", () => {
  const modes = parseModes(edp1.availableModes)
  eq(modes.length, 9, "all nine resolutions are distinct")
  eq(modes[0], { width: 1920, height: 1080, refresh: 60.05 }, "sorted by pixel count, largest first")
  eq(modes[modes.length - 1].width, 640, "smallest last")

  // Descending pixel count throughout.
  let descending = true
  for (let i = 1; i < modes.length; i++) {
    if (modes[i].width * modes[i].height > modes[i - 1].width * modes[i - 1].height) descending = false
  }
  ok(descending, "strictly non-increasing pixel count")

  // The decision under test: refresh rate is not a user choice, so duplicate
  // resolutions collapse to one row carrying the highest rate.
  const dupes = parseModes([
    "3840x2160@30.00Hz",
    "3840x2160@60.00Hz",
    "3840x2160@24.00Hz",
    "1920x1080@60.00Hz",
  ])
  eq(dupes.length, 2, "duplicate resolutions collapse")
  eq(dupes[0], { width: 3840, height: 2160, refresh: 60 }, "highest refresh wins")
  eq(dupes[1].width, 1920, "other resolution retained")

  eq(parseModes([]), [], "no modes")
  eq(parseModes(["nonsense", "also bad"]), [], "unparseable modes dropped")
  eq(parseModes(["bad", "1280x720@60.00Hz"]).length, 1, "good modes survive bad neighbours")
})

group("nativeMode", () => {
  eq(nativeMode(parseModes(edp1.availableModes)), { width: 1920, height: 1080, refresh: 60.05 }, "native is the largest")
  eq(nativeMode([]), null, "no modes yields null")
})

// --- Scale ------------------------------------------------------------------

group("scaleFits", () => {
  ok(scaleFits(1920, 1080, 1.5), "1920x1080 @1.5 = 1280x720, whole")
  ok(scaleFits(1680, 1050, 1.5), "1680x1050 @1.5 = 1120x700, whole")
  ok(scaleFits(1024, 768, 1.0), "scale 1 always fits")
  ok(scaleFits(3840, 2160, 1.5), "3840x2160 @1.5 = 2560x1440, whole")
  ok(!scaleFits(1280, 1024, 1.5), "1280x1024 @1.5 = 853.33, not whole")
  ok(!scaleFits(1024, 768, 1.5), "1024x768 @1.5 = 682.67, not whole")
  ok(!scaleFits(1920, 1080, 0), "zero scale never fits")
  ok(!scaleFits(1920, 1080, -1), "negative scale never fits")
})

group("snapScale", () => {
  // Null means "no surprise" — the row needs no warning.
  eq(snapScale(1920, 1080, 1.5), null, "native mode at current scale is clean")
  eq(snapScale(1680, 1050, 1.5), null, "1680x1050 at 1.5 is clean")
  eq(snapScale(1440, 900, 1.5), null, "1440x900 at 1.5 is clean")

  // Everything 1280-wide is dirty at 1.5 (1280/1.5 = 853.33) and lands on 1.6.
  eq(snapScale(1280, 800, 1.5), 1.6, "1280x800 at 1.5 snaps to 1.6")
  eq(snapScale(1280, 720, 1.5), 1.6, "1280x720 at 1.5 snaps to 1.6")
  eq(snapScale(1024, 768, 1.5), 1.6, "1024x768 at 1.5 snaps to 1.6")
  eq(snapScale(800, 600, 1.5), 1.6, "800x600 at 1.5 snaps to 1.6")

  // THE spike observation: hyprctl returned `ok` and the scale became 1.6.
  eq(snapScale(1280, 1024, 1.5), 1.6, "1280x1024 at 1.5 snaps to 1.6, as observed live")
  ok(scaleFits(1280, 1024, 1.6), "and 1.6 genuinely fits: 800x640")

  // Every snap this returns must itself be valid, or the warning would lie.
  const scale = 1.5
  for (const mode of parseModes(edp1.availableModes)) {
    const snapped = snapScale(mode.width, mode.height, scale)
    if (snapped !== null) {
      ok(
        scaleFits(mode.width, mode.height, snapped),
        `predicted snap for ${mode.width}x${mode.height} is itself whole-pixel`,
      )
      ok(snapped > 0, `predicted snap for ${mode.width}x${mode.height} is positive`)
    }
  }

  // The search must prefer the nearest candidate, and never return a scale
  // further away than one it skipped.
  const snapped = snapScale(1280, 1024, 1.5)
  ok(snapped !== null && Math.abs(snapped - 1.5) <= 0.2, "snap stays near the requested scale")

  eq(snapScale(1920, 1080, 1.0), null, "scale 1 needs no snapping")

  // The panel's actual split at its configured scale: only three of its nine
  // modes are whole-pixel at 1.5, so six rows carry a warning. This is the
  // number the menu's usefulness rests on — a regression that silently flipped
  // modes between clean and dirty would change what the user is warned about.
  const clean = parseModes(edp1.availableModes).filter(
    (m) => snapScale(m.width, m.height, 1.5) === null,
  )
  eq(clean.length, 3, "three of nine modes are clean at scale 1.5")
  eq(
    clean.map((m) => `${m.width}x${m.height}`),
    ["1920x1080", "1680x1050", "1440x900"],
    "and they are exactly these three",
  )
})

// --- Derived geometry -------------------------------------------------------

group("logicalSize", () => {
  eq(logicalSize(1920, 1080, 1.5), { width: 1280, height: 720 }, "the panel's real logical size")
  eq(logicalSize(3840, 2160, 1.5), { width: 2560, height: 1440 }, "the LG's logical size")
  eq(logicalSize(1920, 1080, 1), { width: 1920, height: 1080 }, "unscaled")
  eq(logicalSize(1920, 1080, 0), { width: 1920, height: 1080 }, "zero scale degrades safely")
})

group("diagonalInches", () => {
  // 310x170mm → hypot 353.6mm → 13.92"; this is the Framework/Lenovo panel.
  near(diagonalInches(310, 170), 13.92, 0.02, "laptop panel is ~13.9 inches")
  near(diagonalInches(596, 336), 26.95, 0.05, "a 27-inch external")
  eq(diagonalInches(0, 0), null, "no physical size reported")
  eq(diagonalInches(310, 0), null, "partial physical size is unusable")
  eq(diagonalInches(-1, -1), null, "negative physical size rejected")
})

group("density", () => {
  const diag = diagonalInches(310, 170)
  const d = density(1920, 1080, diag, 1.5)
  near(d?.native ?? null, 158.3, 0.5, "native density of the laptop panel")
  near(d?.effective ?? null, 105.5, 0.5, "effective density at scale 1.5")
  ok((d?.native ?? 0) > (d?.effective ?? 0), "scaling up lowers effective density")

  eq(density(1920, 1080, null, 1.5), null, "no diagonal, no density")
  eq(density(1920, 1080, 0, 1.5), null, "zero diagonal rejected")
  eq(density(1920, 1080, 13.9, 0), null, "zero scale rejected")

  // Rotation invariance: both figures divide a pixel diagonal by a physical one.
  const upright = density(1920, 1080, 13.92, 1)
  const rotated = density(1080, 1920, 13.92, 1)
  near(rotated?.native ?? null, upright?.native ?? 0, 0.001, "density is rotation-invariant")
})

// --- Labels -----------------------------------------------------------------

group("transformLabel", () => {
  eq(transformLabel(0), null, "default transform stays quiet")
  eq(transformLabel(1), "90°", "quarter turn")
  eq(transformLabel(2), "180°", "half turn")
  eq(transformLabel(3), "270°", "three-quarter turn")
  eq(transformLabel(4), "flipped 0°", "flipped")
  eq(transformLabel(5), "flipped 90°", "flipped quarter turn")
})

group("mirrorLabel", () => {
  eq(mirrorLabel("none"), null, "not mirroring stays quiet")
  eq(mirrorLabel(""), null, "empty stays quiet")
  eq(mirrorLabel("DP-2"), "mirroring DP-2", "mirroring is reported")
})

group("formatters", () => {
  eq(formatMode({ width: 1920, height: 1080, refresh: 60 }), "1920×1080", "multiplication sign, not x")
  eq(formatRefresh(60.049), "60 Hz", "refresh rounded")
  eq(formatRefresh(59.94), "60 Hz", "near-60 rounds to 60")
  eq(formatScale(1.5), "1.50", "scale to two decimals")
  eq(formatDiagonal(13.92), "13.9″", "diagonal to one decimal")
  eq(formatDiagonal(null), null, "no diagonal, no label")
})

// --- Keyword construction ---------------------------------------------------

group("monitorKeyword", () => {
  const mode = { width: 1680, height: 1050, refresh: 60.05 }
  eq(
    monitorKeyword(edp1, mode),
    "eDP-1,1680x1050@60.05,2560x0,1.5",
    "carries the monitor's CURRENT position and scale, never auto",
  )

  // Guard the spike's lesson: `auto` for position moved the monitor to 0x0 and
  // `auto` for scale picked 1.6 for 1280x720. Neither belongs in a resolution change.
  ok(!monitorKeyword(edp1, mode).includes("auto"), "no auto in a resolution apply")

  const moved: DisplayInfo = { ...edp1, x: 0, y: 300, scale: 2 }
  eq(monitorKeyword(moved, mode), "eDP-1,1680x1050@60.05,0x300,2", "position and scale passed through")
})

group("repackKeyword", () => {
  eq(
    repackKeyword(edp1),
    "eDP-1,1920x1080@60.05,auto,1.5",
    "re-pack keeps the current mode and scale but hands position to Hyprland",
  )
  ok(repackKeyword(edp1).includes("auto"), "re-pack is the one place auto is correct")
})

group("byPosition", () => {
  const a: DisplayInfo = { ...edp1, name: "A", x: 0, y: 0 }
  const b: DisplayInfo = { ...edp1, name: "B", x: 2560, y: 0 }
  const c: DisplayInfo = { ...edp1, name: "C", x: 0, y: 1440 }
  eq([b, c, a].sort(byPosition).map((m) => m.name), ["A", "C", "B"], "left to right, then top to bottom")
})

// --- Card lines -------------------------------------------------------------
// The exact strings the user reads, pinned against the real panel.

group("specLine", () => {
  eq(specLine(edp1), "13.9″ · 1920×1080 · 60 Hz", "the laptop panel's spec line")

  // monitors.ts documents SIZE as unavailable; with hyprctl it is available,
  // and this is the assertion that keeps it that way.
  ok(specLine(edp1).startsWith("13.9″"), "SIZE field is populated, not omitted")

  // Omitted rather than faked when the panel reports nothing.
  const noPhysical: DisplayInfo = { ...edp1, physicalWidth: 0, physicalHeight: 0 }
  eq(specLine(noPhysical), "1920×1080 · 60 Hz", "no physical size means no diagonal, not a zero")
})

group("scaleLine", () => {
  eq(scaleLine(edp1), "scale 1.50 → 1280×720 · 158/106 dpi", "scale, logical size and both densities")

  const unscaled: DisplayInfo = { ...edp1, scale: 1 }
  eq(scaleLine(unscaled), "scale 1.00 → 1920×1080 · 158/158 dpi", "at scale 1 both densities agree")

  const noPhysical: DisplayInfo = { ...edp1, physicalWidth: 0, physicalHeight: 0 }
  eq(scaleLine(noPhysical), "scale 1.50 → 1280×720", "density dropped when it cannot be computed")
})

group("stateLine", () => {
  // The common case must stay quiet: no rotation, no mirror noise.
  eq(stateLine(edp1), "vrr off · dpms on", "default state reports only vrr and dpms")
  ok(!stateLine(edp1).includes("°"), "no rotation noise when upright")
  ok(!stateLine(edp1).includes("mirror"), "no mirror noise when not mirroring")

  eq(stateLine({ ...edp1, transform: 1 }), "90° · vrr off · dpms on", "rotation surfaces when set")
  eq(stateLine({ ...edp1, mirrorOf: "DP-2" }), "mirroring DP-2 · vrr off · dpms on", "mirroring surfaces when set")
  eq(stateLine({ ...edp1, vrr: true }), "vrr on · dpms on", "vrr on")
  eq(stateLine({ ...edp1, dpmsStatus: false }), "vrr off · dpms off", "dpms off")
  eq(stateLine({ ...edp1, disabled: true }), "vrr off · dpms on · disabled", "disabled surfaces last")
  eq(
    stateLine({ ...edp1, transform: 3, mirrorOf: "HDMI-A-1", vrr: true, disabled: true }),
    "270° · mirroring HDMI-A-1 · vrr on · dpms on · disabled",
    "everything at once, in order",
  )
})

// --- Report -----------------------------------------------------------------

console.log(`\n${checks - failures}/${checks} checks passed`)
if (failures > 0) {
  console.error(`${failures} FAILED`)
  process.exit(1)
}
