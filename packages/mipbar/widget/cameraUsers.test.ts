import {
  normalizeName,
  isCameraSource,
  parsePwDump,
  parseLsof,
  mergeUsers,
  focusable,
  tooltipText,
} from "./cameraUsers"

let checks = 0
let failures = 0

function eq<T>(actual: T, expected: T, label: string): void {
  checks++
  const a = JSON.stringify(actual)
  const e = JSON.stringify(expected)
  if (a !== e) {
    failures++
    console.error(`  FAIL  ${label}\n          expected ${e}\n          actual   ${a}`)
  }
}

function group(name: string, body: () => void): void {
  console.log(`- ${name}`)
  body()
}

const ipu6Source = (state: string) => ({
  id: 108,
  type: "PipeWire:Interface:Node",
  info: {
    state,
    props: {
      "client.id": 43,
      "device.api": "libcamera",
      "media.class": "Video/Source",
      "node.name": "libcamera_input.__SB_.PC00.LNK1",
    },
  },
})

const snapshotClient = {
  id: 114,
  type: "PipeWire:Interface:Client",
  info: {
    props: {
      "application.name": ".snapshot-wrapped",
      "application.process.binary": ".snapshot-wrapped",
      "application.process.id": 189769,
    },
  },
}

const snapshotStream = (state: string) => ({
  id: 115,
  type: "PipeWire:Interface:Node",
  info: {
    state,
    props: { "client.id": 114, "media.class": "Stream/Input/Video", "node.name": "org.gnome.Snapshot" },
  },
})

const link = (id: number, from: number, to: number) => ({
  id,
  type: "PipeWire:Interface:Link",
  info: { state: "active", "output-node-id": from, "input-node-id": to, props: { "client.id": 35 } },
})

const screencastSource = {
  id: 200,
  type: "PipeWire:Interface:Node",
  info: {
    state: "running",
    props: { "media.class": "Video/Source", "node.name": "xdg-desktop-portal-hyprland" },
  },
}

const obsClient = {
  id: 210,
  type: "PipeWire:Interface:Client",
  info: { props: { "application.process.binary": ".obs-wrapped", "application.process.id": 4242 } },
}

const obsStream = {
  id: 211,
  type: "PipeWire:Interface:Node",
  info: { state: "running", props: { "client.id": 210, "media.class": "Stream/Input/Video" } },
}

const firefoxClient = {
  id: 220,
  type: "PipeWire:Interface:Client",
  info: { props: { "application.process.binary": "firefox", "application.process.id": 5151 } },
}

const firefoxStream = {
  id: 221,
  type: "PipeWire:Interface:Node",
  info: { state: "running", props: { "client.id": 220, "media.class": "Stream/Input/Video" } },
}

const dump = (...objects: object[]) => JSON.stringify(objects)

group("normalizeName", () => {
  eq(normalizeName(".snapshot-wrapped"), "snapshot", "strips NixOS wrapper")
  eq(normalizeName("/nix/store/abc-firefox/bin/.firefox-wrapped"), "firefox", "strips path and wrapper")
  eq(normalizeName("obs"), "obs", "plain name unchanged")
})

group("isCameraSource", () => {
  eq(isCameraSource({ "media.class": "Video/Source", "device.api": "libcamera" }), true, "libcamera")
  eq(isCameraSource({ "media.class": "Video/Source", "device.api": "v4l2" }), true, "v4l2")
  eq(isCameraSource({ "media.class": "Video/Source" }), false, "screencast has no device.api")
  eq(isCameraSource({ "media.class": "Stream/Input/Video", "device.api": "v4l2" }), false, "stream is not a source")
})

group("parsePwDump: IPU6 laptop, real capture", () => {
  eq(parsePwDump(dump(ipu6Source("suspended"))), { active: false, users: [] }, "idle camera is off")
  eq(
    parsePwDump(dump(ipu6Source("running"), snapshotClient, snapshotStream("running"), link(116, 108, 115))),
    { active: true, users: [{ pid: 189769, name: "snapshot" }] },
    "snapshot using the camera",
  )
  eq(
    parsePwDump(dump(ipu6Source("suspended"), snapshotClient, snapshotStream("paused"), link(116, 108, 115))),
    { active: false, users: [] },
    "linked but paused stream is not a user",
  )
  eq(
    parsePwDump(dump(ipu6Source("running"))),
    { active: true, users: [] },
    "running source without identified consumer is still in use",
  )
})

group("parsePwDump: screencast", () => {
  eq(
    parsePwDump(dump(ipu6Source("suspended"), screencastSource, obsClient, obsStream, link(212, 200, 211))),
    { active: false, users: [] },
    "screen capture alone does not count",
  )
  eq(
    parsePwDump(
      dump(
        ipu6Source("running"),
        screencastSource,
        obsClient,
        obsStream,
        link(212, 200, 211),
        snapshotClient,
        snapshotStream("running"),
        link(116, 108, 115),
      ),
    ),
    { active: true, users: [{ pid: 189769, name: "snapshot" }] },
    "screencast next to camera lists only the camera user",
  )
})

group("parsePwDump: several users", () => {
  eq(
    parsePwDump(
      dump(
        ipu6Source("running"),
        snapshotClient,
        snapshotStream("running"),
        link(116, 108, 115),
        firefoxClient,
        firefoxStream,
        link(222, 108, 221),
      ),
    ).users,
    [
      { pid: 189769, name: "snapshot" },
      { pid: 5151, name: "firefox" },
    ],
    "both apps are listed",
  )
})

group("parsePwDump: missing data", () => {
  eq(
    parsePwDump(dump(ipu6Source("running"), snapshotStream("running"), link(116, 108, 115))).users,
    [{ pid: null, name: "org.gnome.Snapshot" }],
    "no client object falls back to node name without pid",
  )
  eq(parsePwDump("not json"), { active: false, users: [] }, "invalid json is off")
  eq(parsePwDump("{}"), { active: false, users: [] }, "non-array json is off")
  eq(parsePwDump("[]"), { active: false, users: [] }, "empty dump is off")
})

group("parseLsof", () => {
  eq(parseLsof("p45582\ncwireplumber\n"), [], "wireplumber holding a device is ignored")
  eq(parseLsof("p100\ncpipewire\n"), [], "pipewire is ignored")
  eq(
    parseLsof("p45582\ncwireplumber\np777\nc.ffplay-wrapped\n"),
    [{ pid: 777, name: "ffplay" }],
    "direct v4l2 user is found next to wireplumber",
  )
  eq(parseLsof(""), [], "no output, no users")
})

group("mergeUsers", () => {
  eq(
    mergeUsers([{ pid: 1, name: "firefox" }], [{ pid: 1, name: "firefox-bin" }, { pid: 2, name: "ffplay" }]),
    [
      { pid: 1, name: "firefox" },
      { pid: 2, name: "ffplay" },
    ],
    "deduplicates by pid, first list wins",
  )
  eq(
    mergeUsers([{ pid: null, name: "a" }], [{ pid: null, name: "b" }]),
    [
      { pid: null, name: "a" },
      { pid: null, name: "b" },
    ],
    "users without pid are all kept",
  )
})

group("focusable", () => {
  eq(focusable([{ pid: null, name: "a" }, { pid: 3, name: "b" }]), [{ pid: 3, name: "b" }], "only users with a pid")
})

group("tooltipText", () => {
  eq(tooltipText({ active: true, users: [] }), "Camera in use", "no identified app")
  eq(tooltipText({ active: true, users: [{ pid: 1, name: "firefox" }] }), "Camera: firefox", "one app")
  eq(
    tooltipText({ active: true, users: [{ pid: 1, name: "firefox" }, { pid: 2, name: "snapshot" }] }),
    "Camera: firefox, snapshot",
    "all apps",
  )
})

console.log(`\n${checks - failures}/${checks} checks passed`)
if (failures > 0) {
  console.error(`${failures} FAILED`)
  process.exit(1)
}
