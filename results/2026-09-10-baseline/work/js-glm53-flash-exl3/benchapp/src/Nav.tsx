import { useEffect, useRef, useState } from 'react'

const LINKS = [
  { to: '/', label: 'Home' },
  { to: '/about', label: 'About' },
]

type Props = {
  path: string
  theme: 'light' | 'dark'
  onNavigate: (to: string) => void
  onToggleTheme: () => void
}

export default function Nav({ path, theme, onNavigate, onToggleTheme }: Props) {
  const [open, setOpen] = useState(false)
  const navRef = useRef<HTMLElement>(null)

  useEffect(() => {
    const onClick = (e: MouseEvent) => {
      if (open && navRef.current && !navRef.current.contains(e.target as Node)) {
        setOpen(false)
      }
    }
    document.addEventListener('click', onClick)
    return () => document.removeEventListener('click', onClick)
  }, [open])

  const go = (to: string) => (e: React.MouseEvent) => {
    e.preventDefault()
    onNavigate(to)
    setOpen(false)
  }

  return (
    <header className="nav-header">
      <nav id="main-nav" className="main-nav" ref={navRef} aria-label="Main">
        <a className="brand" href="/" onClick={go('/')}>
          <span aria-hidden="true">◈</span> Nimbus
        </a>
        <div className="nav-actions">
          <button
            id="theme-toggle"
            type="button"
            aria-label={`Switch to ${theme === 'light' ? 'dark' : 'light'} theme`}
            onClick={onToggleTheme}
          >
            {theme === 'light' ? '🌙' : '☀️'}
          </button>
          <button
            id="nav-toggle"
            type="button"
            className="nav-toggle"
            aria-expanded={open}
            aria-controls="nav-links"
            aria-label="Toggle menu"
            onClick={() => setOpen((o) => !o)}
          >
            ☰
          </button>
        </div>
        <ul id="nav-links" className={`nav-links${open ? ' open' : ''}`}>
          {LINKS.map((l) => (
            <li key={l.to}>
              <a
                href={l.to}
                aria-current={path === l.to ? 'page' : undefined}
                onClick={go(l.to)}
              >
                {l.label}
              </a>
            </li>
          ))}
        </ul>
      </nav>
    </header>
  )
}
