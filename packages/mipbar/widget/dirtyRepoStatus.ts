export interface DirtyRepo {
  path: string
  vcs: string
  staged: number
  unstaged: number
  untracked: number
}

export interface DirtyState {
  repos: DirtyRepo[]
  scannedAt: Date | null
  failed: boolean
}

function count(value: unknown): number {
  const n = Number(value)
  return Number.isFinite(n) && n > 0 ? n : 0
}

export function parseDrs(json: string): DirtyRepo[] {
  const data = JSON.parse(json || "[]")
  if (!Array.isArray(data)) throw new Error("drs --json did not return an array")
  return data
    .filter((r) => r && typeof r.path === "string")
    .map((r) => ({
      path: r.path,
      vcs: typeof r.vcs === "string" ? r.vcs : "",
      staged: count(r.status?.staged),
      unstaged: count(r.status?.unstaged),
      untracked: count(r.status?.untracked),
    }))
    .sort((a, b) => a.path.localeCompare(b.path))
}

export function totals(repos: DirtyRepo[]): { staged: number; unstaged: number; untracked: number } {
  return repos.reduce(
    (t, r) => ({
      staged: t.staged + r.staged,
      unstaged: t.unstaged + r.unstaged,
      untracked: t.untracked + r.untracked,
    }),
    { staged: 0, unstaged: 0, untracked: 0 },
  )
}

function clock(date: Date): string {
  const pad = (n: number) => String(n).padStart(2, "0")
  return `${pad(date.getHours())}:${pad(date.getMinutes())}`
}

export function tooltipText(state: DirtyState): string {
  const n = state.repos.length
  const t = totals(state.repos)
  const lines = [
    `${n} dirty ${n === 1 ? "repo" : "repos"}`,
    `${t.staged} staged · ${t.unstaged} unstaged · ${t.untracked} untracked`,
  ]
  if (state.scannedAt) lines.push(`scanned ${clock(state.scannedAt)}`)
  if (state.failed) lines.push("last scan failed")
  return lines.join("\n")
}

export function displayName(path: string): string {
  return path.split("/").filter(Boolean).pop() || path
}

export function shortPath(path: string, home: string): string {
  if (home && (path === home || path.startsWith(`${home}/`))) return `~${path.slice(home.length)}`
  return path
}
