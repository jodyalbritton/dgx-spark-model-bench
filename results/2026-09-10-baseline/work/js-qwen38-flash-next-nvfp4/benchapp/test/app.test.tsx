import App from '../src/App'
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { render, screen, fireEvent, act, within, cleanup } from '@testing-library/react'

function submitEmail(value: string) {
  const input = document.getElementById('email-input') as HTMLInputElement
  fireEvent.change(input, { target: { value } })
  fireEvent.submit(document.getElementById('signup-form') as HTMLFormElement)
}

describe('Pulse landing app', () => {
  beforeEach(() => {
    cleanup()
    window.localStorage.clear()
    window.history.pushState({}, '', '/')
    vi.useRealTimers()
  })

  it('renders the hero and countdown at 100', () => {
    render(<App />)
    expect(document.getElementById('countdown')).toHaveTextContent('100')
    expect(screen.getByRole('heading', { level: 1 })).toBeInTheDocument()
  })

  it('nav marks the current page link with aria-current', () => {
    render(<App />)
    const nav = document.getElementById('main-nav')!
    const home = within(nav).getByRole('link', { name: 'Home' })
    expect(home).toHaveAttribute('aria-current', 'page')
  })

  it('has a nav toggle for phone widths', () => {
    render(<App />)
    expect(document.getElementById('nav-toggle')).toBeInTheDocument()
  })

  it('theme toggle switches the theme', () => {
    render(<App />)
    const root = document.documentElement
    const before = root.getAttribute('data-theme')
    fireEvent.click(document.getElementById('theme-toggle')!)
    const after = root.getAttribute('data-theme')
    expect(after).not.toBe(before)
  })

  it('counts down by one every 5 seconds on a real interval', () => {
    vi.useFakeTimers()
    render(<App />)
    expect(document.getElementById('countdown')).toHaveTextContent('100')
    act(() => {
      vi.advanceTimersByTime(5000)
    })
    expect(document.getElementById('countdown')).toHaveTextContent('99')
    expect(document.getElementById('stat-ticks')).toHaveTextContent('1')
    act(() => {
      vi.advanceTimersByTime(10000)
    })
    expect(document.getElementById('countdown')).toHaveTextContent('97')
    expect(document.getElementById('stat-ticks')).toHaveTextContent('3')
    vi.useRealTimers()
  })

  it('rejects an invalid email and shows an error', () => {
    render(<App />)
    submitEmail('not-an-email')
    expect(document.getElementById('signup-error')).not.toHaveTextContent('')
    expect(document.getElementById('signups')!.children).toHaveLength(0)
  })

  it('adds a valid email to recent signups and updates stats/activity', () => {
    render(<App />)
    submitEmail('ada@example.com')
    const list = document.getElementById('signups')!
    expect(list.children).toHaveLength(1)
    expect(list.textContent).toContain('ada@example.com')
    expect(document.getElementById('stat-signups')).toHaveTextContent('1')
    expect(document.getElementById('signup-error')).toHaveTextContent('')
    const feed = document.getElementById('activity')!
    expect(feed.querySelector('li')!.textContent).toContain('ada@example.com')
  })

  it('rejects a duplicate email and does not add it again', () => {
    render(<App />)
    submitEmail('ada@example.com')
    submitEmail('ada@example.com')
    expect(document.getElementById('signups')!.children).toHaveLength(1)
    expect(document.getElementById('signup-error')).not.toHaveTextContent('')
  })

  it('activity keeps newest first and caps at 10 entries', () => {
    vi.useFakeTimers()
    render(<App />)
    submitEmail('first@example.com')
    act(() => {
      vi.advanceTimersByTime(5000)
    })
    submitEmail('second@example.com')
    const feed = document.getElementById('activity')!
    const items = Array.from(feed.children)
    expect(items.length).toBeLessThanOrEqual(10)
    expect(items[0].textContent).toContain('second@example.com')
    vi.useRealTimers()
  })
})
