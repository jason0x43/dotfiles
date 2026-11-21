export type DiffMode = 'full' | 'collapsed' | 'hidden'

declare module 'claude-code' {
  interface PluginState {
    diffs: {
      mode: DiffMode
      // Rows the person opened (in collapsed mode) or closed (in full mode),
      // keyed by tool_use_id.
      isFlipped: StateFamily<boolean>
    }
  }
}
