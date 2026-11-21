export type SessionRow = {
  id: string
  title: string
  project: string
  mtimeMs: number
  // The folder the session ran in, when its transcript records one.
  cwd?: string
  // The transcript id of the session that started this one (Claude Desktop's
  // `spawnedFrom`); absent for a top-level session.
  parentId?: string
}

declare module 'claude-code' {
  interface PluginState {
    sessions: {
      rows: Shaped<SessionRow[]>
      current: Shaped<string>
      cwd: Shaped<string>
    }
  }
}
