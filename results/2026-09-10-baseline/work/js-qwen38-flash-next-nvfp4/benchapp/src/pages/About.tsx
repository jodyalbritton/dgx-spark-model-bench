export function About() {
  return (
    <div className="page">
      <header className="hero">
        <span className="eyebrow">About</span>
        <h1>We build launch pages that feel alive.</h1>
        <p>
          Pulse is a small, independent studio obsessed with the moment before a
          product goes live — the countdown, the waitlist, the quiet hum of
          momentum.
        </p>
      </header>

      <section className="section">
        <h2>Our story</h2>
        <p className="lead">Founded by three engineers who loved launches.</p>
        <p>
          We started Pulse after shipping too many products with nothing but a
          static page and a spreadsheet. A launch deserves better: a live count,
          a shared sense of anticipation, and a way to gather the people who care
          most. Today thousands of teams use Pulse to turn a page into an event.
        </p>
      </section>

      <section className="section">
        <h2>Principles</h2>
        <div className="feature-grid">
          <article className="feature">
            <h3>Fast</h3>
            <p>Every millisecond of the countdown is honest and real.</p>
          </article>
          <article className="feature">
            <h3>Clear</h3>
            <p>Numbers you can trust, presented without clutter.</p>
          </article>
          <article className="feature">
            <h3>Human</h3>
            <p>Accessible on phones and desktops, in light and dark.</p>
          </article>
        </div>
      </section>
    </div>
  )
}
