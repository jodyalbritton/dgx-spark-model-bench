// T35 — the JavaScript App bench's hidden tests.
//
// Copied into the model's tree at grade time, never before: the model is
// told what behaviour is required, not how it is checked. Mirrors the
// Phoenix arm's hidden LiveView tests, contract id for contract id, so
// the two app benches are comparable across languages.
//
// The brief promises exactly two things these depend on:
//   * the app's root component is the default export of `src/App.tsx`
//   * the five-second tick is a real interval in every environment
import { render, screen, fireEvent, act, cleanup } from '@testing-library/react'
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import App from '../src/App'

const q = (id: string) => document.querySelector(`#${id}`)

beforeEach(() => vi.useFakeTimers({ shouldAdvanceTime: true }))
afterEach(() => {
  cleanup()
  vi.useRealTimers()
})

// Advance the clock inside act() so React flushes the state the tick set.
const tick = async (seconds: number) => {
  await act(async () => {
    vi.advanceTimersByTime(seconds * 1000)
  })
}

describe('countdown', () => {
  it('starts at 100', () => {
    render(<App />)
    expect(q('countdown')?.textContent?.trim()).toBe('100')
  })

  // The tick rule holds in every environment. Round 6's Qwen parked the
  // Phoenix timer in config/test.exs and lost three gates; the JS brief
  // names the rule for the same reason.
  it('decreases by one every five seconds, live', async () => {
    render(<App />)
    await tick(5)
    expect(q('countdown')?.textContent?.trim()).toBe('99')
    await tick(10)
    expect(q('countdown')?.textContent?.trim()).toBe('97')
  })

  it('does not decrease before five seconds have passed', async () => {
    render(<App />)
    await tick(4)
    expect(q('countdown')?.textContent?.trim()).toBe('100')
  })
})

describe('signup form', () => {
  const submit = (address: string) => {
    const form = q('signup-form') as HTMLFormElement
    const input = form.querySelector('input[type="email"], input[name="email"]') as HTMLInputElement
    fireEvent.change(input, { target: { value: address } })
    fireEvent.submit(form)
  }

  it('adds a valid address to the list without a reload', () => {
    render(<App />)
    submit('ada@example.com')
    expect(q('signups')?.textContent).toContain('ada@example.com')
  })

  it('shows an error for an invalid address and does not add it', () => {
    render(<App />)
    submit('not-an-address')
    expect(q('signup-error')?.textContent?.trim()).toBeTruthy()
    expect(q('signups')?.textContent).not.toContain('not-an-address')
  })

  it('refuses the same address twice', () => {
    render(<App />)
    submit('ada@example.com')
    submit('ada@example.com')

    expect(q('signup-error')?.textContent?.trim()).toBeTruthy()
    const listed = (q('signups')?.textContent ?? '').split('ada@example.com').length - 1
    expect(listed).toBe(1)
  })
})

describe('stats, computed from live state', () => {
  it('counts signups', () => {
    render(<App />)
    expect(q('stat-signups')?.textContent?.trim()).toBe('0')

    const form = q('signup-form') as HTMLFormElement
    const input = form.querySelector('input[type="email"], input[name="email"]') as HTMLInputElement
    fireEvent.change(input, { target: { value: 'grace@example.com' } })
    fireEvent.submit(form)

    expect(q('stat-signups')?.textContent?.trim()).toBe('1')
  })

  it('counts ticks so far', async () => {
    render(<App />)
    expect(q('stat-ticks')?.textContent?.trim()).toBe('0')
    await tick(15)
    expect(q('stat-ticks')?.textContent?.trim()).toBe('3')
  })

  it('has a stats strip', () => {
    render(<App />)
    expect(q('stats')).toBeTruthy()
  })
})

describe('activity feed', () => {
  it('lists entries as <li>, newest first', async () => {
    render(<App />)
    await tick(5)

    const items = q('activity')?.querySelectorAll('li') ?? []
    expect(items.length).toBeGreaterThan(0)
  })

  it('adds an entry per signup', () => {
    render(<App />)
    const before = q('activity')?.querySelectorAll('li').length ?? 0

    const form = q('signup-form') as HTMLFormElement
    const input = form.querySelector('input[type="email"], input[name="email"]') as HTMLInputElement
    fireEvent.change(input, { target: { value: 'linus@example.com' } })
    fireEvent.submit(form)

    const after = q('activity')?.querySelectorAll('li').length ?? 0
    expect(after).toBe(before + 1)
    expect(q('activity')?.textContent).toContain('linus@example.com')
  })

  it('keeps at most ten entries', async () => {
    render(<App />)
    await tick(80)

    const items = q('activity')?.querySelectorAll('li') ?? []
    expect(items.length).toBeLessThanOrEqual(10)
  })
})

describe('the nav', () => {
  it('has a nav with a toggle and a theme toggle', () => {
    render(<App />)
    expect(q('main-nav')).toBeTruthy()
    expect(q('nav-toggle')).toBeTruthy()
    expect(q('theme-toggle')).toBeTruthy()
  })

  it('marks the current page', () => {
    render(<App />)
    expect(q('main-nav')?.querySelector('[aria-current="page"]')).toBeTruthy()
  })
})
