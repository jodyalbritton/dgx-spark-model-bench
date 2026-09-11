import { useEffect, useState } from 'react'
import './NavBar.css'

type Props = {
  route: 'home' | 'about'
  onNavigate: (route: 'home' | 'about') => void
}

export function NavBar({ route, onNavigate }: Props) {
  const [menuOpen, setMenuOpen] = useState(false)
  const [theme, setTheme] = useState<'light' | 'dark'>(() => {
    if (typeof window !== 'undefined' && window.matchMedia?.('(prefers-color-scheme: dark)').matches) {
      return 'dark'
    }
    return 'light'
  })

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme)
  }, [theme])

  const go = (next: 'home' | 'about') => {
    setMenuOpen(false)
    onNavigate(next)
  }

  const links = [
    { key: 'home', label: 'Home' },
    { key: 'about', label: 'About' },
  ]

  return (
    <header className="nav-wrap" id="main-nav">
      <nav className="nav" aria-label="Primary">
        <a
          className="brand"
          href="/"
          onClick={(e) => {
            e.preventDefault()
            go('home')
          }}
        >
          Loop&nbsp;Studio
        </a>

        <ul className="nav-links" data-open={menuOpen || undefined}>
          {links.map((link) => (
            <li key={link.key}>
              <a
                href={link.key === 'home' ? '/' : '/about'}
                aria-current={route === link.key ? 'page' : undefined}
                onClick={(e) => {
                  e.preventDefault()
                  go(link.key as 'home' | 'about')
                }}
              >
                {link.label}
              </a>
            </li>
          ))}
        </ul>

        <div className="nav-actions">
          <button
            type="button"
            id="theme-toggle"
            className="icon-btn"
            aria-label="Toggle theme"
            onClick={() => setTheme((t) => (t === 'light' ? 'dark' : 'light'))}
          >
            {theme === 'light' ? (
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                <path
                  d="M12 3v2m0 14v2m9-9h-2M5 12H3m13.5-6.5L15 7m-6 10-1.5 1.5M18.5 18.5 17 17M7 7 5.5 5.5"
                  stroke="currentColor"
                  strokeWidth="1.8"
                  strokeLinecap="round"
                />
                <circle cx="12" cy="12" r="4" stroke="currentColor" strokeWidth="1.8" />
              </svg>
            ) : (
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                <path
                  d="M20.5 14.5A8.5 8.5 0 0 1 9.5 3.5a8.5 8.5 0 1 0 11 11Z"
                  stroke="currentColor"
                  strokeWidth="1.8"
                  strokeLinejoin="round"
                />
              </svg>
            )}
          </button>

          <button
            type="button"
            id="nav-toggle"
            className="icon-btn menu-btn"
            aria-label="Toggle menu"
            aria-expanded={menuOpen}
            onClick={() => setMenuOpen((o) => !o)}
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden="true">
              {menuOpen ? (
                <path d="M5 5l14 14M19 5 5 19" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
              ) : (
                <path d="M3 6h18M3 12h18M3 18h18" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
              )}
            </svg>
          </button>
        </div>
      </nav>
    </header>
  )
}
