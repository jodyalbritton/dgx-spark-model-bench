import { useState } from 'react'
import Nav from './Nav'
import FeatureGrid, { type Feature } from './FeatureGrid'
import { useCounterHub, useRoute, useTheme } from './useAppState'
import './App.css'

const FEATURES: Feature[] = [
  {
    title: 'Ambient sensing',
    body: 'Nimbus reads temperature, air quality and light from every room, without extra hubs.',
    icon: '🌡️',
  },
  {
    title: 'Predictive comfort',
    body: 'On-device models learn your routine and pre-adjust your home before you ask.',
    icon: '🧠',
  },
  {
    title: 'Private by design',
    body: 'All data stays on your network. Nothing leaves the house — ever.',
    icon: '🔒',
  },
  {
    title: 'One-tap automations',
    body: 'Compose lighting, heating and sound into scenes you can trigger from anywhere.',
    icon: '⚡',
  },
  {
    title: 'Open integrations',
    body: 'Works with the 40+ smart platforms you already own, out of the box.',
    icon: '🔌',
  },
  {
    title: 'Offline first',
    body: 'The internet goes down; your home keeps running exactly as configured.',
    icon: '📡',
  },
]

function Home() {
  const { countdown, ticks, signups, activity, error, addSignup } = useCounterHub()
  const [email, setEmail] = useState('')

  const submit = (e: React.FormEvent) => {
    e.preventDefault()
    if (addSignup(email.trim())) setEmail('')
  }

  return (
    <main className="page">
      <section className="hero" aria-labelledby="hero-title">
        <p className="eyebrow">Launching soon</p>
        <h1 id="hero-title">Meet Nimbus, the home that thinks ahead</h1>
        <p className="hero-sub">
          A calm, private smart-home OS that learns your routines and tunes your
          space — no subscriptions, no cloud lock-in.
        </p>
        <p className="countdown-wrap">
          Early-access window closes in{' '}
          <span id="countdown" className="countdown">
            {countdown}
          </span>{' '}
          units
        </p>
      </section>

      <section id="stats" className="stats-strip" aria-label="Live stats">
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
          <span className="stat-label">Live ticks</span>
        </div>
      </section>

      <section className="panel" aria-label="Newsletter signup">
        <h2>Join the waitlist</h2>
        <form id="signup-form" onSubmit={submit} noValidate>
          <label htmlFor="signup-email">Email address</label>
          <input
            id="signup-email"
            type="email"
            name="email"
            placeholder="you@example.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
          <button type="submit">Sign up</button>
        </form>
        <p id="signup-error" className="signup-error" role="alert">
          {error ?? ''}
        </p>
        {signups.length > 0 && (
          <div>
            <h3>Recent signups</h3>
            <ul id="signups" className="signups-list">
              {signups.map((s) => (
                <li key={s}>{s}</li>
              ))}
            </ul>
          </div>
        )}
      </section>

      <section aria-label="Recent activity">
        <h2>Live activity</h2>
        <ul id="activity" className="activity-feed">
          {activity.map((a) => (
            <li key={a.id} className={`activity-${a.kind}`}>
              {a.label}
            </li>
          ))}
        </ul>
      </section>

      <section aria-labelledby="features-title">
        <h2 id="features-title">Why Nimbus</h2>
        <FeatureGrid features={FEATURES} />
      </section>
    </main>
  )
}

function About() {
  return (
    <main className="page">
      <section className="hero" aria-labelledby="about-title">
        <h1 id="about-title">About Nimbus Labs</h1>
        <p className="hero-sub">
          We are a small team of engineers and designers who believe technology
          at home should be quiet, respectful and yours.
        </p>
      </section>
      <section aria-labelledby="story-title" className="panel">
        <h2 id="story-title">Our story</h2>
        <p>
          Nimbus started as a weekend project to tame a house full of
          incompatible gadgets. Three years later it runs our own homes — and
          soon, yours.
        </p>
      </section>
      <section aria-labelledby="values-title">
        <h2 id="values-title">What we value</h2>
        <FeatureGrid
          features={[
            {
              title: 'Privacy',
              body: 'Your home data never touches our servers. Full stop.',
              icon: '🔒',
            },
            {
              title: 'Simplicity',
              body: 'If it needs a manual, we redesign it until it does not.',
              icon: '✨',
            },
            {
              title: 'Longevity',
              body: 'Hardware you own, firmware you can inspect, updates for a decade.',
              icon: '🌱',
            },
          ]}
        />
      </section>
    </main>
  )
}

export default function App() {
  const { path, navigate } = useRoute()
  const { theme, toggle } = useTheme()

  return (
    <div className="app-shell">
      <Nav
        path={path}
        theme={theme}
        onNavigate={navigate}
        onToggleTheme={toggle}
      />
      {path === '/about' ? <About /> : <Home />}
      <footer className="site-footer">
        <p>© 2026 Nimbus Labs. Crafted in the mountains.</p>
      </footer>
    </div>
  )
}
