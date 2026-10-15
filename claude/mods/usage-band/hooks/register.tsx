import { atom, read, update } from 'claude-code'
import type { Register, SessionRateLimit } from 'claude-code'

import type { Limits, Window } from '../types'

const limits = atom({ plugin: 'usage-band', key: 'limits' } as const, {
  fiveHour: null,
  weekly: null,
} as Limits)

const pick = (all: SessionRateLimit[], kind: string): Window | null => {
  const found = all.find(r => r.kind === kind)
  return found ? { percentUsed: found.percentUsed, resetsAt: found.resetsAt } : null
}

const toLimits = (all: SessionRateLimit[]): Limits => ({
  fiveHour: pick(all, 'five_hour'),
  weekly: pick(all, 'seven_day'),
})

// Time until the window resets in its two largest units ('3h 10m', '2d 4h',
// '45m'), or '' when unknown or past.
const untilReset = (resetsAt: string | undefined, now: number): string => {
  if (!resetsAt) return ''
  const ms = Date.parse(resetsAt) - now
  if (!(ms > 0)) return ''
  const mins = Math.max(1, Math.round(ms / 60000))
  const days = Math.floor(mins / 1440)
  const hours = Math.floor((mins % 1440) / 60)
  if (days > 0) return `${days}d ${hours}h`
  if (hours > 0) return `${hours}h ${mins % 60}m`
  return `${mins}m`
}

type Level = 'inactive' | 'warning' | 'error'

const levelOf = (pct: number): Level =>
  pct > 80 ? 'error' : pct >= 50 ? 'warning' : 'inactive'

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const result = await next(e)
    const usage = await $.session.usage()
    await update($, limits, () => toLimits(usage.rateLimits))
    return result
  })

  on('session.measure', async ($, e, next) => {
    if (e.changed.includes('rateLimits')) {
      await update($, limits, () => toLimits(e.rateLimits))
    }
    return next(e)
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    // Desktop app only; the terminal keeps its own band.
    if (e.surface !== 'desktop') return next(e)

    const current = await read($, limits)
    if (e.props.hasSurvey || (!current.fiveHour && !current.weekly)) {
      return next(e)
    }

    const { Box, Text } = $.ui.resolve(e)
    const now = await $.clock.now()
    const part = (label: string, w: Window | null) => {
      if (!w) return [<Text color="subtle">{label}  —</Text>]
      const pct = Math.round(w.percentUsed)
      const until = untilReset(w.resetsAt, now)
      return [
        <Text color="subtle">{label}  </Text>,
        <Text bold color={levelOf(pct)}>
          {pct}%
        </Text>,
        <Text color="subtle">{until ? `  ${until}` : ''}</Text>,
      ]
    }

    return (
      <Box flexDirection="row" justifyContent="flex-end" width="100%">
        {part('5H', current.fiveHour)}
        <Text dimColor>   │   </Text>
        {part('WK', current.weekly)}
      </Box>
    )
  })
}
