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

// 'here': the sessions of this session's folder; 'all': every folder's.
export type SessionScope = 'here' | 'all'

export type SessionList = {
  scope: SessionScope
  list: SessionRow[]
  // False until a scan has finished, so an empty list reads as "none".
  isLoaded: boolean
}

declare module 'claude-code' {
  interface PluginState {
    sessions: {
      rows: Shaped<SessionList>
      scope: Shaped<SessionScope>
      current: Shaped<string>
      cwd: Shaped<string>
    }
  }
}
