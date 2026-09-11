import './AboutPage.css'

export function AboutPage() {
  return (
    <div className="about">
      <section className="about-hero">
        <span className="hero-eyebrow">About us</span>
        <h1>The story behind Loop Studio</h1>
        <p className="about-sub">
          Loop Studio began with a simple belief: work should feel like a
          rhythm, not a scramble. We build calm tools for people who do deep,
          focused work.
        </p>
      </section>

      <section className="about-body">
        <div className="about-block">
          <h2>Our mission</h2>
          <p>
            We help teams turn scattered tasks into one continuous, flowing
            loop — so effort compounds instead of resetting every day.
          </p>
        </div>
        <div className="about-block">
          <h2>What we value</h2>
          <p>
            Focus, privacy, and craft. We design slow, deliberate software,
            and we never compromise on keeping your data yours.
          </p>
        </div>
        <div className="about-block">
          <h2>Where we're headed</h2>
          <p>
            We're launching the first public version soon. Join the waitlist
            from the home page to be first in line.
          </p>
        </div>
      </section>
    </div>
  )
}
