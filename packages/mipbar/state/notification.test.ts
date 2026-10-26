import {
  isScreenshot,
  parseCache,
  parseNotifyLine,
  parseNotifyReply,
  plainText,
  relativeTime,
  screenshotPath,
  serializeNotifications,
  themedIcon,
  type NotificationRecord,
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
const SENDER = ":1.100"
const COOKIE = 42

function notifyLine(data: unknown[], sender = SENDER, cookie = COOKIE): string {
  return JSON.stringify({
    type: "method_call",
    sender,
    cookie,
    interface: "org.freedesktop.Notifications",
    member: "Notify",
    payload: { type: "susssasa{sv}i", data },
  })
}

function replyLine(caller: string, cookie: number, id: number): string {
  return JSON.stringify({
    type: "method_return",
    destination: caller,
    reply_cookie: cookie,
    payload: { type: "u", data: [id] },
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

const shot = screenshot as NotificationRecord

group("parseNotifyLine", () => {
  ok(screenshot !== null, "screenshot line parses")
  eq(shot.appName, "Hyprshot", "application name")
  eq(shot.summary, "Schermafbeelding opgeslagen", "summary")
  eq(shot.body, "2026-10-23-120000_hyprshot.png", "body")
  eq(
    shot.image,
    "/home/pim/Pictures/Screenshots/2026-10-23-120000_hyprshot.png",
    "image path hint",
  )
  eq(
    shot.actions,
    [
      { id: "default", label: "Tonen" },
      { id: "annotate", label: "Bewerken" },
    ],
    "actions",
  )
  eq(shot.receivedAt, NOW, "arrival time")
  eq(shot.id, 0, "new notification has no replaces id")
  eq(shot.caller, SENDER, "caller")
  eq(shot.cookie, COOKIE, "cookie")
  eq(shot.key, `${SENDER}:${COOKIE}:${NOW}`, "record key")

  const replaced = parseNotifyLine(
    notifyLine(["App", 7, "", "summary", "", [], {}, 0], SENDER, 43),
    NOW,
  )
  eq(replaced?.id, 7, "replaces id")

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
  eq(parseNotifyLine(replyLine(SENDER, COOKIE, 293)), null, "Notify reply")
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
  eq(
    parseNotifyLine(
      notifyLine(["App", 0, "", "summary", "body", [], {}]),
    ),
    null,
    "too few arguments",
  )
})

group("parseNotifyReply", () => {
  eq(
    parseNotifyReply(replyLine(SENDER, COOKIE, 293)),
    { caller: SENDER, cookie: COOKIE, id: 293 },
    "notification id",
  )
  eq(parseNotifyReply('{"type":"method_return"'), null, "truncated reply")
  eq(parseNotifyReply(notifyLine([])), null, "call is not a reply")
  eq(
    parseNotifyReply(
      JSON.stringify({
        type: "method_return",
        destination: SENDER,
        reply_cookie: COOKIE,
        payload: { type: "u", data: ["293"] },
      }),
    ),
    null,
    "non-numeric id",
  )
})

group("screenshot detection", () => {
  ok(isScreenshot(shot), "action pair is a screenshot")
  eq(
    screenshotPath(shot, "/home/pim/.cache/hyprshot/last"),
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
    notifyLine(["App", 0, "", "summary", "", ["default"], {}, 0]),
    NOW,
  )
  eq(oddActions?.actions, [], "odd action list is ignored")
  ok(
    oddActions !== null && !isScreenshot(oddActions),
    "incomplete action pair is no screenshot",
  )
})

group("icons", () => {
  const absoluteIcon = parseNotifyLine(
    notifyLine(["App", 0, "/tmp/app-icon.png", "summary", "", [], {}, 0]),
    NOW,
  )
  eq(absoluteIcon?.image, "/tmp/app-icon.png", "absolute app icon is the image")
  eq(
    absoluteIcon === null ? null : themedIcon(absoluteIcon),
    null,
    "absolute icon is not themed",
  )

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
  const encoded = serializeNotifications([shot])
  eq(parseCache(encoded), [shot], "round trip")
  eq(parseCache(JSON.stringify(shot)), [shot], "legacy single record")
  eq(parseCache('{"appName":"App"'), [], "truncated cache")
  eq(parseCache("{}"), [], "incomplete cache")
  eq(parseCache("[]"), [], "empty cache")
  eq(parseCache(encoded).length, 1, "one record")

  const many = Array.from({ length: 60 }, (_, index) => ({
    ...shot,
    key: `key-${index}`,
    summary: `summary ${index}`,
    receivedAt: NOW + index,
  }))
  eq(parseCache(serializeNotifications(many)).length, 50, "cache is capped")
  eq(parseCache(serializeNotifications(many))[0].summary, "summary 0", "cache keeps order")

  const invalid = JSON.parse(encoded)
  invalid.push({
    appName: "App",
    appIcon: "",
    summary: "summary",
    body: "",
    image: "",
    actions: [{ id: "default" }],
    receivedAt: NOW,
  })
  eq(parseCache(JSON.stringify(invalid)).length, 1, "invalid entry is dropped")
})

console.log(
  checks === 0
    ? "no checks ran"
    : `${checks - failures}/${checks} checks passed`,
)
process.exit(failures === 0 ? 0 : 1)
