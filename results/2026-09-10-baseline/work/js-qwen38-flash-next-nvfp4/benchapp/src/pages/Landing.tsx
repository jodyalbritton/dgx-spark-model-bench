import { useEffect, useRef, useState } from 'react'
import type { FormEvent } from 'react'
import { FeatureGrid } from '../components/FeatureGrid'
import { Link } from '../lib/router'

const START = 100
const TICK_MS = 5000
const MAX_ACTIVITY = 10

interface ActivityItem {
  id: number
  kind: 'signup' | 'tick'
  text: string
}

const features = [
  {
    glyph: '⚡',
    title: 'Instant launch',
    body: 'Ship your waitlist page in minutes with zero configuration.',
  },
  {
    glyph: '🎯',
    title: 'Live signals',
    body: 'Watch signups and time-to-launch update in real time.',
  },
  {
    glyph: '🎨',
    title: 'Themed out of the box',
    body: 'Light and dark layouts that feel native on any device.',
  },
  {
    glyph: '🔒',
    title: 'Private by default',
    body: 'Your subscriber list stays in your account. Always.',
  },
]

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

export function Landing() {
  const [count, setCount] = useState(START)
  const [ticks, setTicks] = useState(0)
  const [signups, setSignups] = useState<string[]>([])
  const [activity, setActivity] = useState<ActivityItem[]>([])
  const [email, setEmail] = useState('')
  const [error, setError] = useState('')
  const nextId = useRef(1)

  useEffect(() => {
    const id = setInterval(() => {
      setCount((c) => (c > 0 ? c - 1 : c))
      setTicks((t) => t + 1)
      setActivity((a) => {
        const item: ActivityItem = {
          id: nextId.current++,
          kind: 'tick',
          text: 'Countdown ticked down by one',
        }
        return [item, ...a].slice(0, MAX_ACTIVITY)
      })
    }, TICK_MS)
    return () => clearInterval(id)
  }, [])

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault()
    const value = email.trim()
    if (!EMAIL_RE.test(value)) {
      setError('Please enter a valid email address.')
      return
    }
    if (signups.includes(value)) {
      setError('That email is already on the list.')
      return
    }
    setSignups((s) => [value, ...s])
    setActivity((a) => {
      const item: ActivityItem = {
        id: nextId.current++,
        kind: 'signup',
        text: `${value} joined the waitlist`,
      }
      return [item, ...a].slice(0, MAX_ACTIVITY)
    })
    setError('')
    setEmail('')
  }

  return (
    <div className="page">
      <header className="hero">
        <span className="eyebrow">Pulse · Launch countdown</span>
        <h1>The waitlist that counts down for you.</h1>
        <p>
          Pulse turns a single landing page into a live launch event — signups,
          momentum, and a ticking countdown, all in one place.
        </p>
        <div className="hero-cta">
          <a className="btn btn-primary" href="#signup">
            Join the waitlist
          </a>
          <Link className="btn btn-ghost" to="/features">
            Explore features
          </Link>
        </div>

        <div className="countdown-card">
          <div className="label">T-minus to launch</div>
          <div id="countdown" role="timer" aria-live="polite">
            {count}
          </div>
        </div>
      </header>

      <section id="stats" aria-label="Live statistics">
        <div className="stat">
          <div className="value" id="stat-signups">
            {signups.length}
          </div>
          <div className="caption">Signups so far</div>
        </div>
        <div className="stat">
          <div className="value" id="stat-ticks">
            {ticks}
          </div>
          <div className="caption">Countdown ticks</div>
        </div>
      </section>

      <section className="section">
        <h2>Everything you need to launch</h2>
        <p className="lead">Built-in tools that work the moment you do.</p>
        <FeatureGrid features={features} />
      </section>

      <section className="section" id="signup">
        <h2>Join the launch list</h2>
        <p className="lead">Be first in line when the countdown hits zero.</p>
        <div className="signup-wrap">
          <form id="signup-form" noValidate onSubmit={handleSubmit}>
            <input
              id="email-input"
              type="email"
              name="email"
              aria-label="Email address"
              placeholder="you@company.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              aria-describedby="signup-error"
            />
            <button className="btn btn-primary" type="submit">
              Notify me
            </button>
          </form>
          <p id="signup-error" role="alert">
            {error}
          </p>

          <div className="recent">
            <h4>Recent signups</h4>
            <ul id="signups">
              {signups.map((s, i) => (
                <li key={`${s}-${i}`}>{s}</li>
              ))}
            </ul>
            {signups.length === 0 && (
              <p className="muted">No signups yet — be the first.</p>
            )}
          </div>
        </div>
      </section>

      <section className="section">
        <h2>Activity</h2>
        <p className="lead">The latest events, newest first.</p>
        <ul id="activity">
          {activity.map((a) => (
            <li key={a.id} data-kind={a.kind}>
              <span className="dot" aria-hidden="true" />
              {a.text}
            </li>
          ))}
        </ul>
        {activity.length === 0 && (
          <p className="muted">Waiting for the first event…</p>
        )}
      </section>
    </div>
  )
}
