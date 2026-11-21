import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

import type { SessionRow } from '../types'

const PANE = 'sessions'
const LIMIT = 40
const HEAD = 64 * 1024
const TAIL = 256 * 1024
const REFRESH_MS = 30_000

// Change a tag when that value's fields change: it declines what an earlier
// version stored, which outlives a reload.
const rows = atom({ plugin: 'sessions', key: 'rows' } as const, [], {
  shape: 'rows-3',
})
const current = atom({ plugin: 'sessions', key: 'current' } as const, '', {
  shape: 'current-1',
})
// The folder this session runs in: its sessions are drawn at full strength.
const cwd = atom({ plugin: 'sessions', key: 'cwd' } as const, '', {
  shape: 'cwd-1',
})

// ---------------------------------------------------------------------------
// Transcripts (<projects>/<folder>/<id>.jsonl)

type Parsed = {
  cwd?: string
  firstPrompt?: string
  aiTitle?: string
  customTitle?: string
}

function promptText(content: unknown): string | undefined {
  if (typeof content === 'string') return content
  if (Array.isArray(content)) {
    for (const block of content) {
      if (block && block.type === 'text' && typeof block.text === 'string') {
        return block.text
      }
    }
  }
  return undefined
}

function isRealPrompt(text: string): boolean {
  const t = text.trimStart()
  return t !== '' && !t.startsWith('<') && !t.startsWith('Caveat:')
}

// Reads JSONL lines into `out`. Lines cut at a range's edges fail to parse and
// are skipped.
function parseLines(text: string, out: Parsed) {
  for (const line of text.split('\n')) {
    if (line === '') continue
    let row: any
    try {
      row = JSON.parse(line)
    } catch {
      continue
    }
    if (!row || typeof row !== 'object') continue
    if (row.type === 'custom-title' && typeof row.customTitle === 'string') {
      out.customTitle = row.customTitle
    } else if (row.type === 'ai-title' && typeof row.aiTitle === 'string') {
      out.aiTitle = row.aiTitle
    } else if (row.type === 'user' && !row.isSidechain && !row.isMeta) {
      if (!out.cwd && typeof row.cwd === 'string') out.cwd = row.cwd
      if (!out.firstPrompt) {
        const text = promptText(row.message?.content)
        if (text && isRealPrompt(text)) out.firstPrompt = text
      }
    }
  }
}

function oneLine(text: string, max = 120): string {
  const flat = text.replace(/\s+/g, ' ').trim()
  return flat.length > max ? flat.slice(0, max - 1) + '…' : flat
}

function basename(path: string): string {
  const parts = path.split('/').filter(Boolean)
  return parts[parts.length - 1] ?? path
}

type FileRef = {
  id: string
  path: string
  folder: string
  size: number
  mtimeMs: number
}

// Module variables start over on a reload; these caches are only a speedup.
const transcriptCache = new Map<string, { mtimeMs: number; parsed: Parsed }>()

async function readTranscript($: any, f: FileRef): Promise<Parsed> {
  const hit = transcriptCache.get(f.path)
  if (hit && hit.mtimeMs === f.mtimeMs) return hit.parsed

  const parsed: Parsed = {}
  if (f.size <= HEAD + TAIL) {
    parseLines(await $.fs.read(f.path), parsed)
  } else {
    parseLines(await $.fs.read(f.path, { length: HEAD }), parsed)
    const offset = f.size - TAIL
    parseLines(await $.fs.read(f.path, { offset, length: TAIL }), parsed)
  }
  transcriptCache.set(f.path, { mtimeMs: f.mtimeMs, parsed })
  return parsed
}

async function listTranscripts($: any, projectsDir: string): Promise<FileRef[]> {
  const files: FileRef[] = []
  for (const dir of await $.fs.list(projectsDir)) {
    if (dir.kind !== 'dir') continue
    const folderPath = `${projectsDir}/${dir.name}`
    const entries = await $.fs.list(folderPath).catch(() => [])
    for (const entry of entries) {
      if (entry.kind !== 'file' || !entry.name.endsWith('.jsonl')) continue
      if (entry.size === 0) continue
      files.push({
        id: entry.name.replace(/\.jsonl$/, ''),
        path: `${folderPath}/${entry.name}`,
        folder: dir.name,
        size: entry.size,
        mtimeMs: entry.mtimeMs,
      })
    }
  }
  return files.sort((a, b) => b.mtimeMs - a.mtimeMs)
}

// ---------------------------------------------------------------------------
// Claude Desktop's session metadata, a private and undocumented store:
// ~/Library/Application Support/Claude/claude-code-sessions/<account>/<org>/*.json
// Any failure here leaves the list flat, never broken.

type DesktopMeta = {
  desktopId: string
  title?: string
  parentDesktopId?: string
  isArchived: boolean
}

type DesktopIndex = {
  byCli: Map<string, DesktopMeta>
  cliByDesktop: Map<string, string>
  childrenByDesktop: Map<string, string[]>
}

const emptyIndex = (): DesktopIndex => ({
  byCli: new Map(),
  cliByDesktop: new Map(),
  childrenByDesktop: new Map(),
})

const desktopCache = new Map<string, { mtimeMs: number; meta: any }>()

async function readDesktop($: any): Promise<DesktopIndex> {
  const index = emptyIndex()
  const home = await $.env.get('HOME').catch(() => undefined)
  if (!home) return index
  const root = `${home}/Library/Application Support/Claude/claude-code-sessions`
  if (!(await $.fs.exists(root).catch(() => false))) return index

  for (const account of await $.fs.list(root).catch(() => [])) {
    if (account.kind !== 'dir') continue
    const accountPath = `${root}/${account.name}`
    for (const org of await $.fs.list(accountPath).catch(() => [])) {
      if (org.kind !== 'dir') continue
      const orgPath = `${accountPath}/${org.name}`
      for (const entry of await $.fs.list(orgPath).catch(() => [])) {
        if (entry.kind !== 'file' || !entry.name.endsWith('.json')) continue
        const path = `${orgPath}/${entry.name}`
        let meta: any
        const hit = desktopCache.get(path)
        if (hit && hit.mtimeMs === entry.mtimeMs) {
          meta = hit.meta
        } else {
          try {
            const o = JSON.parse(await $.fs.read(path))
            // Keep only the few fields used; the files run to 500 KB.
            meta = {
              sessionId: o.sessionId,
              cliIds: [o.cliSessionId, o.lastAssistantCliSessionId],
              title: o.title,
              parent: o.spawnedFrom?.sessionId,
              isArchived: o.isArchived === true,
            }
          } catch {
            meta = null
          }
          desktopCache.set(path, { mtimeMs: entry.mtimeMs, meta })
        }
        if (!meta || typeof meta.sessionId !== 'string') continue
        const value: DesktopMeta = {
          desktopId: meta.sessionId,
          title: typeof meta.title === 'string' ? meta.title : undefined,
          parentDesktopId: typeof meta.parent === 'string' ? meta.parent : undefined,
          isArchived: meta.isArchived,
        }
        for (const cli of meta.cliIds) {
          if (typeof cli === 'string' && cli) index.byCli.set(cli, value)
        }
        if (typeof meta.cliIds[0] === 'string' && meta.cliIds[0]) {
          index.cliByDesktop.set(meta.sessionId, meta.cliIds[0])
        }
        if (value.parentDesktopId) {
          const siblings = index.childrenByDesktop.get(value.parentDesktopId) ?? []
          siblings.push(meta.sessionId)
          index.childrenByDesktop.set(value.parentDesktopId, siblings)
        }
      }
    }
  }
  return index
}

// ---------------------------------------------------------------------------

async function toRow(
  $: any,
  f: FileRef,
  desktop: DesktopIndex,
): Promise<SessionRow | null> {
  const parsed = await readTranscript($, f)
  const meta = desktop.byCli.get(f.id)
  const title =
    parsed.customTitle ?? meta?.title ?? parsed.aiTitle ?? parsed.firstPrompt
  if (!title) return null
  // Desktop's side questions; hidden, and so are any sessions under them.
  if (/^\s*btw:/i.test(title)) return null
  const parentId = meta?.parentDesktopId
    ? desktop.cliByDesktop.get(meta.parentDesktopId)
    : undefined
  return {
    id: f.id,
    title: oneLine(title),
    project: parsed.cwd ? basename(parsed.cwd) : f.folder,
    mtimeMs: f.mtimeMs,
    ...(parsed.cwd ? { cwd: parsed.cwd } : {}),
    ...(parentId && parentId !== f.id ? { parentId } : {}),
  }
}

async function scan($: any) {
  const { transcriptPath } = await $.session.info()
  if (!transcriptPath) return
  // <projects>/<project folder>/<session>.jsonl
  const projectDir = transcriptPath.slice(0, transcriptPath.lastIndexOf('/'))
  const projectsDir = projectDir.slice(0, projectDir.lastIndexOf('/'))

  const [files, desktop] = await Promise.all([
    listTranscripts($, projectsDir),
    readDesktop($).catch(emptyIndex),
  ])
  const fileById = new Map(files.map(f => [f.id, f]))

  const found = new Map<string, SessionRow>()
  for (const f of files) {
    if (found.size >= LIMIT) break
    if (desktop.byCli.get(f.id)?.isArchived) continue
    const row = await toRow($, f, desktop).catch(() => null)
    if (row) found.set(row.id, row)
  }

  // Bring in parents older than the cut, so each child sits under its own.
  for (const row of [...found.values()]) {
    let parentId = row.parentId
    for (let depth = 0; parentId && depth < 10; depth++) {
      if (found.has(parentId)) break
      const f = fileById.get(parentId)
      if (!f) break
      const parent = await toRow($, f, desktop).catch(() => null)
      if (!parent) break
      found.set(parent.id, parent)
      parentId = parent.parentId
    }
  }

  // Bring in every child of a shown session, however old, and theirs in turn.
  // Archived children stay hidden, as in Claude Desktop.
  const queue = [...found.keys()]
  while (queue.length > 0) {
    const id = queue.shift()!
    const desktopId = desktop.byCli.get(id)?.desktopId
    if (!desktopId) continue
    for (const childDesktopId of desktop.childrenByDesktop.get(desktopId) ?? []) {
      const childId = desktop.cliByDesktop.get(childDesktopId)
      if (!childId || found.has(childId)) continue
      if (desktop.byCli.get(childId)?.isArchived) continue
      const f = fileById.get(childId)
      if (!f) continue
      const child = await toRow($, f, desktop).catch(() => null)
      if (!child) continue
      found.set(child.id, child)
      queue.push(child.id)
    }
  }

  await update($, rows, () => [...found.values()])
}

// ---------------------------------------------------------------------------
// Finding a session that is already running.
//
// Claude Code keeps <config>/sessions/<pid>.json for each running process,
// naming its sessionId; Rex reports each terminal's foreground pid. A match is
// the tab to jump to.

async function configDir($: any): Promise<string | undefined> {
  const { transcriptPath } = await $.session.info()
  if (!transcriptPath) return undefined
  // <config>/projects/<project folder>/<session>.jsonl
  const parts = transcriptPath.split('/')
  return parts.slice(0, -3).join('/')
}

async function runningPids($: any, id: string): Promise<Set<number>> {
  const pids = new Set<number>()
  const dir = await configDir($)
  if (!dir) return pids
  for (const entry of await $.fs.list(`${dir}/sessions`).catch(() => [])) {
    if (entry.kind !== 'file' || !entry.name.endsWith('.json')) continue
    try {
      const o = JSON.parse(await $.fs.read(`${dir}/sessions/${entry.name}`))
      if (o.sessionId === id && typeof o.pid === 'number') pids.add(o.pid)
    } catch {}
  }
  if (pids.size === 0) return pids
  // A file left by a process that has since died names nothing running.
  const ps = await $.process
    .run(['ps', '-o', 'pid=', '-p', [...pids].join(',')])
    .catch(() => undefined)
  if (!ps) return pids
  const alive = new Set<number>(
    ps.stdout.split('\n').map((l: string) => Number(l.trim())).filter(Boolean),
  )
  return new Set([...pids].filter(pid => alive.has(pid)))
}

async function rexJson($: any, argv: string[]): Promise<any> {
  const run = await $.process.run(['rex', ...argv])
  if (run.exitCode !== 0) throw new Error(run.stderr.trim() || 'rex failed')
  return JSON.parse(run.stdout)
}

type RexPlace = {
  sessionId: string
  sessionLabel: string
  windowId: string
  blockId: string
}

async function findRexTab($: any, pids: Set<number>): Promise<RexPlace | undefined> {
  const { sessions } = await rexJson($, ['ls', '--json'])
  for (const session of sessions ?? []) {
    const listed = await rexJson($, ['block', 'ls', '-s', session.session_id, '--json'])
      .catch(() => undefined)
    for (const block of listed?.blocks ?? []) {
      if (!String(block.flavor ?? '').includes('terminal')) continue
      const proc = await rexJson($, [
        'block', 'call', '-s', session.session_id, '-b', block.block_id, 'process',
      ]).catch(() => undefined)
      const pid = proc?.foreground?.pid
      if (typeof pid === 'number' && pids.has(pid)) {
        return {
          sessionId: session.session_id,
          sessionLabel: session.label ?? session.session_id,
          windowId: block.window_id,
          blockId: block.block_id,
        }
      }
    }
  }
  return undefined
}

// Asks each Rex app to show a tab. The server's active tab is not what an app
// shows: the app keeps its own, and takes this request only with Remote
// Control turned on in its Settings (under Rex Server). Answers whether one did.
async function showInApp($: any, sessionId: string, windowId: string): Promise<boolean> {
  const { clients } = await rexJson($, ['client', 'ls', '--json'])
  const apps = (clients ?? []).filter((c: any) => c.info?.kind === 'app')
  let isShown = false
  for (const app of apps) {
    const run = await $.process.run([
      'rex', 'do', '-C', app.client_id, 'session.select',
      `session_id=${sessionId}`, `window_id=${windowId}`,
    ])
    if (run.exitCode === 0) isShown = true
  }
  return isShown
}

const REMOTE_CONTROL_HINT = 'Turn on Remote Control in Rex Settings to switch to it.'

// Focuses the tab in its Rex session, then asks the app to show it.
async function jumpTo($: any, place: RexPlace, here: string | undefined) {
  await rexJson($, [
    'api', 'call', 'session.focus_block',
    JSON.stringify({ session_id: place.sessionId, block_id: place.blockId }),
  ])
  if (await showInApp($, place.sessionId, place.windowId).catch(() => false)) return
  const where = place.sessionId === here
    ? 'another tab'
    : `Rex session "${place.sessionLabel}"`
  $.ui.toast(`Already open in ${where}. ${REMOTE_CONTROL_HINT}`)
}

// ---------------------------------------------------------------------------
// Drawing

function bucket(ms: number, now: number): string {
  const startOfToday = new Date(now)
  startOfToday.setHours(0, 0, 0, 0)
  const today = startOfToday.getTime()
  const day = 24 * 60 * 60 * 1000
  if (ms >= today) return 'Today'
  if (ms >= today - day) return 'Yesterday'
  if (ms >= today - 6 * day) return 'Previous 7 days'
  if (ms >= today - 29 * day) return 'Previous 30 days'
  return 'Older'
}

type Node = { row: SessionRow; children: Node[]; latest: number }

function buildTree(list: readonly SessionRow[]): Node[] {
  const nodes = new Map<string, Node>()
  for (const row of list) {
    nodes.set(row.id, { row, children: [], latest: row.mtimeMs })
  }
  const roots: Node[] = []
  for (const node of nodes.values()) {
    const parent = node.row.parentId ? nodes.get(node.row.parentId) : undefined
    if (parent) parent.children.push(node)
    else roots.push(node)
  }
  // A thread is as recent as its newest member.
  const settle = (node: Node, seen: Set<string>): number => {
    if (seen.has(node.row.id)) return node.latest
    seen.add(node.row.id)
    for (const child of node.children) {
      node.latest = Math.max(node.latest, settle(child, seen))
    }
    node.children.sort((a, b) => b.latest - a.latest)
    return node.latest
  }
  const seen = new Set<string>()
  for (const root of roots) settle(root, seen)
  return roots.sort((a, b) => b.latest - a.latest)
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const result = await next(e)
    await $.command.register({
      name: 'sessions',
      description: 'Show or hide the recent sessions pane',
    })
    void $.session.id().then(id => update($, current, () => id))
    await update($, cwd, () => e.cwd)
    void scan($).catch(err => $.ui.log(`sessions: ${String(err)}`))
    $.clock.every(REFRESH_MS, () => {
      void scan($).catch(() => {})
    })
    // The pane opens only on /sessions, never by itself.

    return result
  })

  // /sessions: closed → open with the keyboard; open → close. (Typing the
  // command puts the keyboard in the prompt, so the pane never has it here;
  // ctrl+x tab moves the keyboard into an open pane.)
  on('command.run', { command: 'sessions' }, async $ => {
    const pane = (await $.ui.panes()).find(p => p.id === PANE)
    if (pane?.isPlaced) {
      await $.ui.close({ id: PANE })
      return { text: 'Sessions pane closed.' }
    }
    await $.ui.open({ id: PANE, title: 'Sessions', focus: true, closeOnEscape: true })
    void scan($).catch(() => {})
    return { text: 'Sessions pane opened.' }
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Text, Button } = $.ui.resolve(e)
    const list = await read($, rows)
    const me = await read($, current)
    const here = await read($, cwd)
    const now = Date.now()

    // A session from this folder: /resume, as if typed; the session switches
    // and this pane goes with it. From another folder: a new Rex tab there
    // running `claude --resume`, when this session runs inside Rex.
    const switchTo = async (s: SessionRow) => {
      // The pane closes on any press; a failure still shows as a toast.
      await $.ui.close({ id: PANE }).catch(() => {})
      try {
        // Already running somewhere: jump there rather than open it twice.
        const pids = await runningPids($, s.id)
        if (pids.size > 0) {
          const mine = await $.env.get('REX_SESSION').catch(() => undefined)
          const place = mine
            ? await findRexTab($, pids).catch(() => undefined)
            : undefined
          if (place) {
            await jumpTo($, place, mine)
          } else {
            $.ui.toast('That session is already open outside Rex, such as in Claude Desktop.')
          }
          return
        }

        const rexSession = s.cwd && s.cwd !== here
          ? await $.env.get('REX_SESSION').catch(() => undefined)
          : undefined
        if (s.cwd && rexSession) {
          const shell = (await $.env.get('SHELL').catch(() => undefined)) || '/bin/zsh'
          const label = basename(s.cwd)
          const run = await $.process.run([
            'rex', 'window', 'new', '-s', rexSession, '-c', s.cwd,
            '--shell', shell, '--interactive', '--focus', '--json', label,
            '--', 'claude', '--resume', s.id,
          ])
          if (run.exitCode !== 0) {
            throw new Error(run.stderr.trim() || `rex exited ${run.exitCode}`)
          }
          // `--focus` makes it the session's active tab; the app shows it
          // only when asked.
          let windowId: string | undefined
          try {
            windowId = JSON.parse(run.stdout).window_id
          } catch {}
          if (typeof windowId === 'string') {
            const isShown = await showInApp($, rexSession, windowId).catch(() => false)
            if (!isShown) {
              $.ui.toast(`Opened in a new Rex tab, "${label}". ${REMOTE_CONTROL_HINT}`)
            }
          }
          return
        }
        await $.command.run({ command: 'resume', args: s.id })
      } catch (err) {
        $.ui.toast(`Couldn't switch session: ${String(err)}`)
      }
    }

    if (list.length === 0) {
      return <Text dimColor>Looking for sessions…</Text>
    }

    const out: any[] = []
    const drawn = new Set<string>()
    // The cursor starts on the first session drawn that isn't this one.
    let hasAutoFocus = false
    const draw = (node: Node, depth: number) => {
      if (drawn.has(node.row.id)) return
      drawn.add(node.row.id)
      const s = node.row
      const isMe = s.id === me
      // A child's arrow sits one column right of where its parent's title
      // starts: parent titles at 2, 5, 8…, so arrows at 3, 6, 9…
      const indent = ' '.repeat(3 * depth)
      const mark = isMe ? '● ' : depth > 0 ? '↳ ' : '  '
      const autoFocus = !isMe && !hasAutoFocus
      if (autoFocus) hasAutoFocus = true
      out.push(
        isMe ? (
          <Text wrap="truncate-end" bold color="claude">
            {indent}
            {mark}
            {s.title}
          </Text>
        ) : (
          <Button
            key={s.id}
            label={s.title}
            plain
            dimColor={s.cwd !== here}
            {...(autoFocus ? { autoFocus: true as const } : {})}
            onPress={() => switchTo(s)}
          >
            <Text wrap="truncate-end">
              {indent}
              {mark}
              {s.title}
            </Text>
          </Button>
        ),
      )
      for (const child of node.children) draw(child, depth + 1)
    }

    let last = ''
    for (const root of buildTree(list)) {
      const group = bucket(root.latest, now)
      if (group !== last) {
        out.push(
          <Box marginTop={last === '' ? 0 : 1}>
            <Text bold dimColor>
              {group}
            </Text>
          </Box>,
        )
        last = group
      }
      draw(root, 0)
    }

    return <Box flexDirection="column">{out}</Box>
  })
}
