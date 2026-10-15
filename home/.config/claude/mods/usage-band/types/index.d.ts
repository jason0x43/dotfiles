export type Window = { percentUsed: number; resetsAt?: string }
export type Limits = { fiveHour: Window | null; weekly: Window | null }

declare module 'claude-code' {
  interface PluginState {
    'usage-band': { limits: Limits }
  }
}
