import { useState } from 'react'
import { Link } from '../lib/router'

interface NavProps {
  path: string
  theme: 'light' | 'dark'
  onToggleTheme: () => void
}

const links = [
  { to: '/', label: 'Home' },
  { to: '/features', label: 'Features' },
  { to: '/about', label: 'About' },
]

export function Nav({ path, theme, onToggleTheme }: NavProps) {
  const [open, setOpen] = useState(false)
  const isActive = (to: string) =>
    to === '/' ? path === '/' : path === to || path.startsWith(to + '/')

  return (
    <nav id="main-nav" aria-label="Main">
      <div className="nav-inner">
        <Link to="/" className="brand" onNavigate={() => setOpen(false)}>
          Pulse
        </Link>

        <div
          className="nav-links"
          id="nav-menu"
          data-open={open ? 'true' : 'false'}
        >
          {links.map((l) => (
            <Link
              key={l.to}
              to={l.to}
              className="nav-link"
              aria-current={isActive(l.to) ? 'page' : undefined}
              onNavigate={() => setOpen(false)}
            >
              {l.label}
            </Link>
          ))}
        </div>

        <div className="nav-actions">
          <button
            id="theme-toggle"
            type="button"
            className="icon-btn"
            onClick={onToggleTheme}
            aria-label={`Switch to ${theme === 'dark' ? 'light' : 'dark'} theme`}
            aria-pressed={theme === 'dark'}
          >
            {theme === 'dark' ? '☀' : '☾'}
          </button>
          <button
            id="nav-toggle"
            type="button"
            className="icon-btn"
            aria-label="Toggle navigation menu"
            aria-expanded={open}
            aria-controls="nav-menu"
            onClick={() => setOpen((o) => !o)}
          >
            ☰
          </button>
        </div>
      </div>
    </nav>
  )
}
