import { useEffect, useRef, useState } from 'react'
import { NavBar } from './components/NavBar'
import { HomePage } from './pages/HomePage'
import { AboutPage } from './pages/AboutPage'
import './App.css'

type Route = 'home' | 'about'

export type ActivityItem = {
  id: number
  kind: 'signup' | 'tick'
  label: string
  at: number
}

function routeFromPath(path: string): Route {
  return path.startsWith('/about') ? 'about' : 'home'
}

function App() {
  const [route, setRoute] = useState<Route>(() => routeFromPath(window.location.pathname))
  const [countdown, setCountdown] = useState(100)
  const [signups, setSignups] = useState<string[]>([])
  const [signupError, setSignupError] = useState('')
  const [activity, setActivity] = useState<ActivityItem[]>([])
  const idRef = useRef(0)
  const countdownRef = useRef(100)

  const pushActivity = (kind: ActivityItem['kind'], label: string) => {
    setActivity((prev) =>
      [{ id: idRef.current++, kind, label, at: Date.now() }, ...prev].slice(0, 10),
    )
  }

  useEffect(() => {
    const onPop = () => setRoute(routeFromPath(window.location.pathname))
    window.addEventListener('popstate', onPop)
    return () => window.removeEventListener('popstate', onPop)
  }, [])

  const navigate = (next: Route) => {
    const path = next === 'about' ? '/about' : '/'
    window.history.pushState({}, '', path)
    setRoute(next)
  }

  useEffect(() => {
    const timer = setInterval(() => {
      const next = Math.max(0, countdownRef.current - 1)
      countdownRef.current = next
      setCountdown(next)
      pushActivity('tick', `Launch countdown ticked to ${next}`)
    }, 5000)
    return () => clearInterval(timer)
  }, [])

  const withSignup = (email: string): boolean => {
    const normalized = email.trim().toLowerCase()
    if (!normalized) {
      setSignupError('Please enter an email address.')
      return false
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalized)) {
      setSignupError('That doesn\u2019t look like a valid email address.')
      return false
    }
    if (signups.includes(normalized)) {
      setSignupError('This email is already on the list.')
      return false
    }
    setSignups((prev) => [...prev, normalized])
    pushActivity('signup', normalized)
    setSignupError('')
    return true
  }

  return (
    <div className="app">
      <NavBar
        route={route}
        onNavigate={navigate}
      />
      <main className="app-main">
        {route === 'home' ? (
          <HomePage
            countdown={countdown}
            signups={signups}
            signupError={signupError}
            activity={activity}
            onSignup={withSignup}
          />
        ) : (
          <AboutPage />
        )}
      </main>
    </div>
  )
}

export default App
