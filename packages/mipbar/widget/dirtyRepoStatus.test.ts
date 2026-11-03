import { parseDrs, totals, tooltipText, displayName, shortPath } from "./dirtyRepoStatus"

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

const sample = JSON.stringify([
  { path: "/home/pim/mipnix", vcs: "git", status: { staged: 0, unstaged: 3, untracked: 1 } },
  { path: "/home/pim/gh.ekstranix/flaker.eu", vcs: "jj", status: { staged: 52, unstaged: 0, untracked: 0 } },
])

group("parseDrs", () => {
  eq(parseDrs("[]"), [], "empty array")
  eq(parseDrs(""), [], "empty output")
  eq(
    parseDrs(sample).map((r) => r.path),
    ["/home/pim/gh.ekstranix/flaker.eu", "/home/pim/mipnix"],
    "sorted by path",
  )
  eq(parseDrs(sample)[1], { path: "/home/pim/mipnix", vcs: "git", staged: 0, unstaged: 3, untracked: 1 }, "fields")
  eq(parseDrs('[{"path":"/x"}]')[0], { path: "/x", vcs: "", staged: 0, unstaged: 0, untracked: 0 }, "missing status")
  let threw = false
  try {
    parseDrs('{"path":"/x"}')
  } catch {
    threw = true
  }
  eq(threw, true, "non-array throws")
})

group("totals", () => {
  eq(totals(parseDrs(sample)), { staged: 52, unstaged: 3, untracked: 1 }, "summed")
  eq(totals([]), { staged: 0, unstaged: 0, untracked: 0 }, "none")
})

group("tooltipText", () => {
  const at = new Date(2026, 10, 3, 14, 4)
  eq(
    tooltipText({ repos: parseDrs(sample), scannedAt: at, failed: false }),
    "2 dirty repos\n52 staged · 3 unstaged · 1 untracked\nscanned 14:04",
    "overview",
  )
  eq(
    tooltipText({ repos: parseDrs(sample).slice(0, 1), scannedAt: at, failed: true }),
    "1 dirty repo\n52 staged · 0 unstaged · 0 untracked\nscanned 14:04\nlast scan failed",
    "singular and failure",
  )
  eq(tooltipText({ repos: [], scannedAt: null, failed: true }), "0 dirty repos\n0 staged · 0 unstaged · 0 untracked\nlast scan failed", "never scanned")
})

group("names", () => {
  eq(displayName("/home/pim/gh.mipmip/rme"), "rme", "basename")
  eq(displayName("/home/pim/mipnix/"), "mipnix", "trailing slash")
  eq(shortPath("/home/pim/gh.mipmip/rme", "/home/pim"), "~/gh.mipmip/rme", "home abbreviated")
  eq(shortPath("/home/pimx/repo", "/home/pim"), "/home/pimx/repo", "prefix is not home")
  eq(shortPath("/srv/repo", "/home/pim"), "/srv/repo", "outside home")
})

console.log(`\n${checks - failures}/${checks} checks passed`)
if (failures > 0) {
  console.error(`${failures} FAILED`)
  process.exit(1)
}
