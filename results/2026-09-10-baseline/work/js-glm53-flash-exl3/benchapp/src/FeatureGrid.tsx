export type Feature = {
  title: string
  body: string
  icon: string
}

export default function FeatureGrid({ features }: { features: Feature[] }) {
  return (
    <ul className="feature-grid">
      {features.map((f) => (
        <li className="feature-card" key={f.title}>
          <span className="feature-icon" aria-hidden="true">
            {f.icon}
          </span>
          <h3>{f.title}</h3>
          <p>{f.body}</p>
        </li>
      ))}
    </ul>
  )
}
