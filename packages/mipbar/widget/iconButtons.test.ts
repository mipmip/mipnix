import { readFileSync } from "node:fs"
import { join } from "node:path"

const root = join(process.cwd(), "mipbar")
const read = (path: string) => readFileSync(join(root, path), "utf8")

const notIcons = new Set(["Tray", "QuickSettings"])

let checks = 0
let failures = 0

function ok(cond: boolean, label: string): void {
  checks++
  if (!cond) {
    failures++
    console.error(`  FAIL  ${label}`)
  }
}

const bar = read("widget/Bar.tsx")
const end = bar.slice(bar.indexOf('$type="end"'))
const widgets = [...end.matchAll(/<([A-Z]\w*) \/>/g)]
  .map((m) => m[1])
  .filter((name) => !notIcons.has(name))

console.log("- end section widgets carry BarIcon")
ok(widgets.length > 0, "found widgets in the end section")
for (const name of widgets) {
  const source = read(`widget/${name}.tsx`)
  const tagged = /<(menubutton|button)\b(?:(?!<\w)[\s\S])*?\bclass=[^\n]*BarIcon/.test(source)
  ok(tagged, `${name}: clickable has the BarIcon class`)
}

console.log("- stylesheet keeps icon buttons styled")
const style = read("style.scss")
ok(!/all:\s*unset/.test(style.slice(0, style.indexOf(".QuickSettingsPanel"))), "no `all: unset` in the bar rules")
ok(/\.BarIcon > button,\s*button\.BarIcon\s*\{/.test(style), "shared BarIcon rule present")

console.log(`\n${checks - failures}/${checks} checks passed`)
if (failures > 0) {
  console.error(`${failures} FAILED`)
  process.exit(1)
}
