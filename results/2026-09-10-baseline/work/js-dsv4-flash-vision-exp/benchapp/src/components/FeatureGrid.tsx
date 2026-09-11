import './FeatureGrid.css'

export type Feature = {
  icon: string
  title: string
  text: string
}

const DEFAULT_FEATURES: Feature[] = [
  {
    icon: '⚡',
    title: 'Instant sync',
    text: 'Every loop syncs across your devices in real time, so your flow never breaks.',
  },
  {
    icon: '🧭',
    title: 'Guided focus',
    text: 'A gentle, adaptive guide keeps you on track through the whole work session.',
  },
  {
    icon: '📊',
    title: 'Deep insights',
    text: 'See where your time really goes with rich, readable activity analytics.',
  },
  {
    icon: '🔒',
    title: 'Private by default',
    text: 'Your data is encrypted and stays yours. Nothing is sold, ever.',
  },
]

export function FeatureGrid({ features = DEFAULT_FEATURES }: { features?: Feature[] }) {
  return (
    <div className="feature-grid" role="list">
      {features.map((feature) => (
        <article className="feature-card" role="listitem" key={feature.title}>
          <span className="feature-icon" aria-hidden="true">
            {feature.icon}
          </span>
          <h3>{feature.title}</h3>
          <p>{feature.text}</p>
        </article>
      ))}
    </div>
  )
}
