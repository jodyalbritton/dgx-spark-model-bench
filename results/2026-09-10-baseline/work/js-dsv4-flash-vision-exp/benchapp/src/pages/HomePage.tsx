import { useState } from 'react'
import { FeatureGrid } from '../components/FeatureGrid'
import type { ActivityItem } from '../App'
import './HomePage.css'

type Props = {
  countdown: number
  signups: string[]
  signupError: string
  activity: ActivityItem[]
  onSignup: (email: string) => boolean
}

export function HomePage({ countdown, signups, signupError, activity, onSignup }: Props) {
  const [email, setEmail] = useState('')

  const submit = (e: React.FormEvent) => {
    e.preventDefault()
    const ok = onSignup(email)
    if (ok) setEmail('')
  }

  const ticks = 100 - countdown

  return (
    <div className="home">
      <section className="hero">
        <span className="hero-eyebrow">Introducing Loop Studio</span>
        <h1>Find your flow,<br />keep it looping.</h1>
        <p className="hero-sub">
          Loop Studio is a calm workspace that turns scattered work into one
          continuous rhythm. Launching soon — the countdown is on.
        </p>

        <div className="countdown-panel">
          <span className="countdown-label">Launching in</span>
          <span id="countdown" className="countdown-value">
            {countdown}
          </span>
          <span className="countdown-unit">ticks</span>
        </div>

        <a className="cta" href="#signup">
          Join the waitlist
        </a>
      </section>

      <section className="section" >
        <h2>Everything in one loop</h2>
        <FeatureGrid />
      </section>

      <section className="section signup" id="signup">
        <div className="signup-card">
          <h2>Get early access</h2>
          <p className="signup-sub">Join the list and be first in line when Loop Studio arrives.</p>
          <form id="signup-form" className="signup-form" onSubmit={submit} noValidate aria-label="Get early access">
            <input
              type="email"
              className="signup-input"
              placeholder="you@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              aria-label="Email address"
              aria-describedby="signup-error"
            />
            <button type="submit" className="cta cta-primary">
              Sign up
            </button>
          </form>
          <p id="signup-error" className="signup-error" aria-live="polite">
            {signupError}
          </p>

          <h3 className="recent-heading">Recent signups</h3>
          <ul id="signups" className="signups-list">
            {signups.length === 0 ? (
              <li className="signups-empty">No signups yet.</li>
            ) : (
              signups.map((s) => (
                <li key={s} className="signup-item">
                  {s}
                </li>
              ))
            )}
          </ul>
        </div>
      </section>

      <section className="section">
        <h2>Live stats</h2>
        <div id="stats" className="stats">
          <div className="stat">
            <span id="stat-signups" className="stat-value">
              {signups.length}
            </span>
            <span className="stat-label">Signups</span>
          </div>
          <div className="stat">
            <span id="stat-ticks" className="stat-value">
              {ticks}
            </span>
            <span className="stat-label">Countdown ticks</span>
          </div>
        </div>
      </section>

      <section className="section">
        <h2>Activity feed</h2>
        <ul id="activity" className="activity">
          {activity.length === 0 ? (
            <li className="activity-empty">Activity will appear here.</li>
          ) : (
            activity.map((item) => (
              <li key={item.id} className="activity-item" data-kind={item.kind}>
                <span className="activity-dot" aria-hidden="true" />
                <span className="activity-text">
                  {item.kind === 'signup' ? (
                    <>New signup: <strong>{item.label}</strong></>
                  ) : (
                    item.label
                  )}
                </span>
              </li>
            ))
          )}
        </ul>
      </section>
    </div>
  )
}
