import '@testing-library/jest-dom/vitest'
import { cleanup, fireEvent, render, screen, act } from '@testing-library/react'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import App from './App'

beforeEach(() => {
  window.history.pushState({}, '', '/')
  vi.useFakeTimers()
})

afterEach(() => {
  cleanup()
  vi.useRealTimers()
})

describe('nav', () => {
  it('marks the current page link with aria-current', () => {
    render(<App />)
    expect(screen.getByRole('link', { name: 'Home' })).toHaveAttribute(
      'aria-current',
      'page',
    )
    expect(screen.getByRole('link', { name: 'About' })).not.toHaveAttribute(
      'aria-current',
    )
  })

  it('navigates to /about from the nav', () => {
    render(<App />)
    fireEvent.click(screen.getByRole('link', { name: 'About' }))
    expect(window.location.pathname).toBe('/about')
    expect(screen.getByRole('link', { name: 'About' })).toHaveAttribute(
      'aria-current',
      'page',
    )
    expect(screen.getByRole('heading', { name: /about nimbus labs/i })).toBeInTheDocument()
  })

  it('mobile menu opens behind the toggle', () => {
    render(<App />)
    const toggle = screen.getByRole('button', { name: /toggle menu/i })
    expect(toggle).toHaveAttribute('aria-expanded', 'false')
    fireEvent.click(toggle)
    expect(toggle).toHaveAttribute('aria-expanded', 'true')
  })

  it('theme toggle flips the document theme', () => {
    render(<App />)
    const toggle = screen.getByRole('button', { name: /theme/i })
    const before = document.documentElement.dataset.theme
    fireEvent.click(toggle)
    expect(document.documentElement.dataset.theme).not.toBe(before)
  })
})

describe('countdown and ticks', () => {
  it('starts at 100 and decreases by 1 every 5 seconds', () => {
    render(<App />)
    const el = document.getElementById('countdown')!
    expect(el.textContent).toBe('100')
    act(() => vi.advanceTimersByTime(5000))
    expect(el.textContent).toBe('99')
    act(() => vi.advanceTimersByTime(10000))
    expect(el.textContent).toBe('97')
  })

  it('counts ticks so far in the stats strip', () => {
    render(<App />)
    const ticks = document.getElementById('stat-ticks')!
    expect(ticks.textContent).toBe('0')
    act(() => vi.advanceTimersByTime(15000))
    expect(ticks.textContent).toBe('3')
  })

  it('adds one activity entry per tick, newest first', () => {
    render(<App />)
    const feed = document.getElementById('activity')!
    expect(feed.querySelectorAll('li')).toHaveLength(0)
    act(() => vi.advanceTimersByTime(10000))
    const items = feed.querySelectorAll('li')
    expect(items).toHaveLength(2)
    expect(items[0].textContent).toMatch(/pulse/i)
  })
})

describe('signup form', () => {
  const submitWith = (value: string) => {
    const input = screen.getByLabelText(/email address/i)
    fireEvent.change(input, { target: { value } })
    fireEvent.submit(document.getElementById('signup-form')!)
  }

  it('rejects an invalid address with an error and does not add it', () => {
    render(<App />)
    submitWith('not-an-email')
    expect(document.getElementById('signup-error')!.textContent).toMatch(
      /valid email/i,
    )
    expect(document.getElementById('signups')).toBeNull()
    expect(document.getElementById('stat-signups')!.textContent).toBe('0')
  })

  it('adds a valid address to recent signups and the stats strip', () => {
    render(<App />)
    submitWith('ada@example.com')
    expect(
      [...document.getElementById('signups')!.querySelectorAll('li')].map(
        (li) => li.textContent,
      ),
    ).toEqual(['ada@example.com'])
    expect(document.getElementById('signup-error')!.textContent).toBe('')
    expect(document.getElementById('stat-signups')!.textContent).toBe('1')
  })

  it('rejects a duplicate address', () => {
    render(<App />)
    submitWith('ada@example.com')
    submitWith('ada@example.com')
    expect(document.getElementById('signup-error')!.textContent).toMatch(
      /already/i,
    )
    expect(
      document.getElementById('signups')!.querySelectorAll('li'),
    ).toHaveLength(1)
  })

  it('adds one activity entry per signup and caps the feed at 10', () => {
    render(<App />)
    for (let i = 0; i < 8; i++) submitWith(`user${i}@example.com`)
    act(() => vi.advanceTimersByTime(10000))
    const items = document.getElementById('activity')!.querySelectorAll('li')
    expect(items).toHaveLength(10)
    // newest first: the last tick is the newest entry
    expect(items[0].textContent).toMatch(/pulse/i)
  })
})

describe('feature grid', () => {
  it('renders a grid of feature cards on the landing page', () => {
    render(<App />)
    expect(document.querySelectorAll('.feature-card').length).toBeGreaterThan(3)
  })
})
