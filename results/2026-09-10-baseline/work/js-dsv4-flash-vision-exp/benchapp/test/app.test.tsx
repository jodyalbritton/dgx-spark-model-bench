import { describe, it, expect, afterEach, vi, beforeEach } from 'vitest'
import { render, screen, fireEvent, act, waitFor, cleanup } from '@testing-library/react'
import App from '../src/App'

beforeEach(() => {
  vi.useFakeTimers()
  window.history.pushState({}, '', '/')
})

afterEach(() => {
  cleanup()
  vi.useRealTimers()
})

describe('App', () => {
  it('renders a hero on the home page', () => {
    render(<App />)
    expect(screen.getByRole('heading', { name: /find your flow/i })).toBeInTheDocument()
  })

  it('marks the current page link with aria-current', () => {
    render(<App />)
    const homeLink = screen.getByRole('link', { name: 'Home' })
    expect(homeLink).toHaveAttribute('aria-current', 'page')
    fireEvent.click(screen.getByRole('link', { name: 'About' }))
    const aboutLink = screen.getByRole('link', { name: 'About' })
    expect(aboutLink).toHaveAttribute('aria-current', 'page')
  })

  it('navigates to the about page via the nav', () => {
    render(<App />)
    fireEvent.click(screen.getByRole('link', { name: 'About' }))
    expect(screen.getByRole('heading', { name: /the story behind loop studio/i })).toBeInTheDocument()
  })

  it('toggles the theme on click', () => {
    render(<App />)
    const toggle = screen.getByRole('button', { name: /toggle theme/i })
    const initial = document.documentElement.getAttribute('data-theme')
    fireEvent.click(toggle)
    expect(document.documentElement.getAttribute('data-theme')).not.toBe(initial)
  })

  it('starts the countdown at 100 and ticks down every 5 seconds', () => {
    render(<App />)
    expect(screen.getByText('100')).toBeInTheDocument()
    act(() => {
      vi.advanceTimersByTime(5000)
    })
    expect(screen.getByText('99')).toBeInTheDocument()
    act(() => {
      vi.advanceTimersByTime(5000)
    })
    expect(screen.getByText('98')).toBeInTheDocument()
  })

  it('shows tick count in the stats and activity feed', () => {
    render(<App />)
    act(() => {
      vi.advanceTimersByTime(5000)
    })
    expect(document.getElementById('stat-ticks')).toHaveTextContent('1')
    const activityLis = document.querySelectorAll('#activity li')
    expect(activityLis.length).toBeGreaterThan(0)
  })

  it('rejects an invalid email and does not add it', () => {
    render(<App />)
    const input = screen.getByLabelText(/email/i)
    fireEvent.change(input, { target: { value: 'not-an-email' } })
    fireEvent.submit(screen.getByRole('form', { name: /get early access/i }))
    expect(document.getElementById('signup-error')).toHaveTextContent(/valid/i)
    expect(document.getElementById('stat-signups')).toHaveTextContent('0')
  })

  it('adds a valid email to recent signups and updates stats', () => {
    render(<App />)
    const input = screen.getByLabelText(/email/i)
    fireEvent.change(input, { target: { value: 'hello@example.com' } })
    fireEvent.submit(screen.getByRole('form', { name: /get early access/i }))
    expect(screen.getAllByText('hello@example.com').length).toBeGreaterThan(0)
    expect(document.getElementById('stat-signups')).toHaveTextContent('1')
  })

  it('rejects a duplicate email', () => {
    render(<App />)
    const input = screen.getByLabelText(/email/i)
    const form = screen.getByRole('form', { name: /get early access/i })
    fireEvent.change(input, { target: { value: 'dup@example.com' } })
    fireEvent.submit(form)
    expect(document.getElementById('stat-signups')).toHaveTextContent('1')
    fireEvent.change(input, { target: { value: 'dup@example.com' } })
    fireEvent.submit(form)
    expect(document.getElementById('stat-signups')).toHaveTextContent('1')
    expect(document.getElementById('signup-error')).toHaveTextContent(/already/i)
  })

  it('toggles the mobile menu', () => {
    render(<App />)
    const toggle = document.getElementById('nav-toggle')
    fireEvent.click(toggle)
    expect(document.querySelector('.nav-links')).toHaveAttribute('data-open')
  })
})
