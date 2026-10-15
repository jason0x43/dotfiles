import { expect, mock, test } from 'claude-code/testing'

const BAND = {
  component: 'AbovePrompt',
  props: { hasSurvey: false, isWorking: false, maxRows: 10 },
} as const

const HOUR = 3600_000

test('5H/WK labels and timers subtle, percentages bold by level', async ($, on) => {
  const clock = mock.clock(on)
  const now = clock.now()
  on('session.measure', (_$, e) => ({ changed: e.changed }))
  await $.session.measure({
    context: { window: 200000 } as never,
    rateLimits: [
      { kind: 'five_hour', percentUsed: 23.5, resetsAt: new Date(now + 3 * HOUR + 10 * 60000).toISOString() },
      { kind: 'seven_day', percentUsed: 61, resetsAt: new Date(now + 52 * HOUR).toISOString() },
    ],
    changed: ['rateLimits'],
  })
  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ plugin: 'usage-band', surface, ...BAND } as never)
    const find = async (text: string | RegExp) => ((await ui.find({ type: 'Text', text })) as any)?.props
    expect(await find(/^5H/)).toMatchObject({ color: 'subtle' })
    expect(await find(/^WK/)).toMatchObject({ color: 'subtle' })
    expect(await find(/24%/)).toMatchObject({ bold: true, color: 'inactive' })
    expect(await find(/61%/)).toMatchObject({ bold: true, color: 'warning' })
    expect(await find(/3h 10m/)).toMatchObject({ color: 'subtle' })
    expect(await find(/2d 4h/)).toMatchObject({ color: 'subtle' })
    expect(await ui.find({ type: 'Svg' } as never)).toBeUndefined()
    await ui.unmount()
  }

  await $.session.measure({
    context: { window: 200000 } as never,
    rateLimits: [{ kind: 'five_hour', percentUsed: 92 }],
    changed: ['rateLimits'],
  })
  const ui = await $.ui.mount({ plugin: 'usage-band', surface: 'terminal', ...BAND } as never)
  expect(((await ui.find({ type: 'Text', text: /92%/ })) as any).props).toMatchObject({ bold: true, color: 'error' })
  await ui.unmount()
})
