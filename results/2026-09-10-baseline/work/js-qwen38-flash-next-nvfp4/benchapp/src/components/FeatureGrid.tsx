export interface Feature {
  glyph: string
  title: string
  body: string
}

interface FeatureGridProps {
  features: Feature[]
}

export function FeatureGrid({ features }: FeatureGridProps) {
  return (
    <div className="feature-grid">
      {features.map((f) => (
        <article className="feature" key={f.title}>
          <div className="glyph" aria-hidden="true">
            {f.glyph}
          </div>
          <h3>{f.title}</h3>
          <p>{f.body}</p>
        </article>
      ))}
    </div>
  )
}
