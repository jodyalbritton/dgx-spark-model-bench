import { useEffect, useRef, useState } from 'react'

export function useTheme() {
  const [theme, setTheme] = useState<'light' | 'dark'>(() => {
    if (typeof window === 'undefined' || typeof window.matchMedia !== 'function')
      return 'light'
    return window.matchMedia('(prefers-color-scheme: dark)').matches
      ? 'dark'
      : 'light'
  })

  useEffect(() => {
    document.documentElement.dataset.theme = theme
  }, [theme])

  const toggle = () => setTheme((t) => (t === 'light' ? 'dark' : 'light'))
  return { theme, toggle }
}

/** A tiny history-based router: state synced to location.pathname. */
export function useRoute() {
  const [path, setPath] = useState(() => window.location.pathname)

  useEffect(() => {
    const onPop = () => setPath(window.location.pathname)
    window.addEventListener('popstate', onPop)
    return () => window.removeEventListener('popstate', onPop)
  }, [])

  const navigate = (to: string) => {
    if (to !== window.location.pathname) {
      window.history.pushState({}, '', to)
      setPath(to)
    }
  }

  return { path, navigate }
}

export const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

export type Activity = { id: number; kind: 'tick' | 'signup'; label: string }

export function useCounterHub() {
  const [countdown, setCountdown] = useState(100)
  const [ticks, setTicks] = useState(0)
  const [signups, setSignups] = useState<string[]>([])
  const [activity, setActivity] = useState<Activity[]>([])
  const [error, setError] = useState<string | null>(null)
  const idRef = useRef(0)

  useEffect(() => {
    const iv = setInterval(() => {
      setCountdown((c) => c - 1)
      setTicks((t) => t + 1)
      idRef.current += 1
      const id = idRef.current
      setActivity((a) =>
        [{ id, kind: 'tick' as const, label: 'Telemetry pulse received' }, ...a].slice(0, 10),
      )
    }, 5000)
    return () => clearInterval(iv)
  }, [])

  const addSignup = (email: string) => {
    if (!EMAIL_RE.test(email)) {
      setError('Please enter a valid email address.')
      return false
    }
    if (signups.includes(email)) {
      setError('That address is already signed up.')
      return false
    }
    setError(null)
    setSignups((s) => [...s, email])
    idRef.current += 1
    const id = idRef.current
    setActivity((a) =>
      [{ id, kind: 'signup' as const, label: `${email} joined the waitlist` }, ...a].slice(0, 10),
    )
    return true
  }

  return { countdown, ticks, signups, activity, error, addSignup }
}
