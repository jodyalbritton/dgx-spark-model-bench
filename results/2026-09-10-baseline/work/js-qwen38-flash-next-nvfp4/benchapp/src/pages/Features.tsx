import { FeatureGrid } from '../components/FeatureGrid'

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
  {
    glyph: '📈',
    title: 'Momentum charts',
    body: 'See how interest builds as the countdown ticks away.',
  },
  {
    glyph: '🌍',
    title: 'Global edge',
    body: 'Served fast, everywhere your audience already is.',
  },
]

export function Features() {
  return (
    <div className="page">
      <header className="hero">
        <span className="eyebrow">Features</span>
        <h1>Everything Pulse can do.</h1>
        <p>The full toolkit for turning anticipation into signups.</p>
      </header>

      <section className="section">
        <h2>Feature set</h2>
        <p className="lead">Each capability works on its own or together.</p>
        <FeatureGrid features={features} />
      </section>
    </div>
  )
}
