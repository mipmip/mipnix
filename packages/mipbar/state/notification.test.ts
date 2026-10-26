import {
  isScreenshot,
  parseCache,
  parseNotifyLine,
  plainText,
  relativeTime,
  screenshotPath,
  serializeNotification,
  themedIcon,
  type LastNotification,
} from "./notification"

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

function group(name: string, body: () => void): void {
  console.log(`- ${name}`)
  body()
}

const NOW = 1792767879570

function notifyLine(data: unknown[]): string {
  return JSON.stringify({
    type: "method_call",
    interface: "org.freedesktop.Notifications",
    member: "Notify",
    payload: { type: "susssasa{sv}i", data },
  })
}

const screenshot = parseNotifyLine(
  notifyLine([
    "Hyprshot",
    0,
    "",
    "Schermafbeelding opgeslagen",
    "2026-10-23-120000_hyprshot.png",
    ["default", "Tonen", "annotate", "Bewerken"],
    {
      "image-path": {
        type: "s",
        data: "/home/pim/Pictures/Screenshots/2026-10-23-120000_hyprshot.png",
      },
      urgency: { type: "y", data: 1 },
    },
    5000,
  ]),
  NOW,
)

group("parseNotifyLine", () => {
  ok(screenshot !== null, "screenshot line parses")
  eq(screenshot?.appName, "Hyprshot", "application name")
  eq(screenshot?.summary, "Schermafbeelding opgeslagen", "summary")
  eq(screenshot?.body, "2026-10-23-120000_hyprshot.png", "body")
  eq(
    screenshot?.image,
    "/home/pim/Pictures/Screenshots/2026-10-23-120000_hyprshot.png",
    "image path hint",
  )
  eq(
    screenshot?.actions,
    [
      { id: "default", label: "Tonen" },
      { id: "annotate", label: "Bewerken" },
    ],
    "actions",
  )
  eq(screenshot?.receivedAt, NOW, "arrival time")

  eq(
    parseNotifyLine(
      JSON.stringify({
        type: "signal",
        member: "SubscribeV2",
        interface: "org.erikreider.swaync.cc",
      }),
    ),
    null,
    "non-Notify message",
  )
  eq(
    parseNotifyLine(
      '{"type":"method_return","member":"Notify","interface":"org.freedesktop.Notifications"}',
    ),
    null,
    "Notify reply",
  )
  eq(
    parseNotifyLine(
      '{"member":"Notify","interface":"org.freedesktop.Notifications"',
    ),
    null,
    "truncated JSON",
  )
  eq(
    parseNotifyLine(
      notifyLine(["App", 0, "", "summary", "body", [], {}, 0]).replace(
        '"member":"Notify"',
        '"member":"CloseNotification"',
      ),
    ),
    null,
    "wrong member after substring",
  )
})

group("screenshot detection", () => {
  ok(screenshot !== null && isScreenshot(screenshot), "action pair is a screenshot")
  eq(
    screenshot === null
      ? null
      : screenshotPath(screenshot, "/home/pim/.cache/hyprshot/last"),
    "/home/pim/Pictures/Screenshots/2026-10-23-120000_hyprshot.png",
    "uses the notification path",
  )

  const withoutImage = parseNotifyLine(
    notifyLine([
      "Hyprshot",
      0,
      "",
      "Schermafbeelding opgeslagen",
      "",
      ["default", "Tonen", "annotate", "Bewerken"],
      {},
      5000,
    ]),
    NOW,
  )
  ok(
    withoutImage !== null && isScreenshot(withoutImage),
    "detects a screenshot without an image",
  )
  eq(
    withoutImage === null ? null : screenshotPath(withoutImage, "/tmp/last.png"),
    "/tmp/last.png",
    "falls back to the recorded capture",
  )

  const generic = parseNotifyLine(
    notifyLine([
      "Signal",
      0,
      "signal",
      "Nieuw bericht",
      "<b>Hallo</b>",
      ["reply", "Antwoorden", "mark-read", "Gelezen"],
      { "image-path": { type: "s", data: "dialog-information" } },
      5000,
    ]),
    NOW,
  )
  ok(generic !== null && !isScreenshot(generic), "generic actions are not a screenshot")
  eq(
    generic === null ? null : themedIcon(generic),
    "dialog-information",
    "themed icon from image-path",
  )

  const oddActions = parseNotifyLine(
    notifyLine([
      "App",
      0,
      "",
      "summary",
      "",
      ["default"],
      {},
      0,
    ]),
    NOW,
  )
  eq(oddActions?.actions, [], "odd action list is ignored")
  ok(oddActions !== null && !isScreenshot(oddActions), "incomplete action pair is no screenshot")
})

group("icons", () => {
  const absoluteIcon = parseNotifyLine(
    notifyLine([
      "App",
      0,
      "/tmp/app-icon.png",
      "summary",
      "",
      [],
      {},
      0,
    ]),
    NOW,
  )
  eq(absoluteIcon?.image, "/tmp/app-icon.png", "absolute app icon is the image")
  eq(absoluteIcon === null ? null : themedIcon(absoluteIcon), null, "absolute icon is not themed")

  const alias = parseNotifyLine(
    notifyLine([
      "App",
      0,
      "",
      "summary",
      "",
      [],
      { image_path: { type: "s", data: "mail-unread" } },
      0,
    ]),
    NOW,
  )
  eq(alias?.image, "mail-unread", "image_path alias")

  const inline = parseNotifyLine(
    notifyLine([
      "App",
      0,
      "",
      "summary",
      "",
      [],
      { "image-data": { type: "(iiibiiay)", data: [1, 1, 0, 0, 0, 0, 0, 0] } },
      0,
    ]),
    NOW,
  )
  eq(inline?.image, "", "inline image data is dropped")

  const appIcon = parseNotifyLine(
    notifyLine(["App", 0, "dialog-warning", "summary", "", [], {}, 0]),
    NOW,
  )
  eq(
    appIcon === null ? null : themedIcon(appIcon),
    "dialog-warning",
    "themed icon from app icon",
  )
})

group("plainText", () => {
  eq(plainText("<b>Hallo</b> &amp; <i>wereld</i>"), "Hallo & wereld", "tags and entities")
  eq(plainText("&lt;b&gt;"), "<b>", "escaped tags stay text")
  eq(plainText("caf&#233;"), "café", "decimal entity")
  eq(plainText("&#x1F600;"), "😀", "hex entity")
  eq(plainText("1 < 2"), "1 < 2", "a lone angle bracket survives")
  eq(plainText("  regel een\nregel twee  "), "regel een\nregel twee", "trim only")
})

group("relativeTime", () => {
  eq(relativeTime(NOW - 30_000, NOW), "zojuist", "under a minute")
  eq(relativeTime(NOW - 90_000, NOW), "1 min geleden", "one minute")
  eq(relativeTime(NOW - 2 * 3600_000, NOW), "2 uur geleden", "hours")
  eq(relativeTime(NOW - 25 * 3600_000, NOW), "1 dag geleden", "one day")
  eq(relativeTime(NOW - 3 * 24 * 3600_000, NOW), "3 dagen geleden", "days")
  eq(relativeTime(NOW + 5000, NOW), "zojuist", "future timestamp")
})

group("cache", () => {
  const encoded = serializeNotification(screenshot as LastNotification)
  eq(parseCache(encoded), screenshot, "round trip")
  eq(parseCache('{"appName":"App"'), null, "truncated cache")
  eq(parseCache("{}"), null, "incomplete cache")
  eq(
    parseCache(
      JSON.stringify({
        appName: "App",
        appIcon: "",
        summary: "summary",
        body: "",
        image: "",
        actions: [{ id: "default" }],
        receivedAt: NOW,
      }),
    ),
    null,
    "action without label",
  )
})

console.log(
  checks === 0
    ? "no checks ran"
    : `${checks - failures}/${checks} checks passed`,
)
process.exit(failures === 0 ? 0 : 1)
