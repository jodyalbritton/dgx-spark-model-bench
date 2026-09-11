import { useCallback, useEffect, useState } from 'react'
import type { AnchorHTMLAttributes, MouseEvent } from 'react'

function currentPath(): string {
  if (typeof window === 'undefined') return '/'
  return window.location.pathname
}

export function useRoute() {
  const [path, setPath] = useState<string>(currentPath)

  useEffect(() => {
    const onPop = () => setPath(currentPath())
    window.addEventListener('popstate', onPop)
    return () => window.removeEventListener('popstate', onPop)
  }, [])

  const navigate = useCallback((to: string) => {
    if (to !== window.location.pathname) {
      window.history.pushState({}, '', to)
    }
    setPath(to)
  }, [])

  return { path, navigate }
}

interface LinkProps extends AnchorHTMLAttributes<HTMLAnchorElement> {
  to: string
  onNavigate?: () => void
}

export function Link({ to, onNavigate, onClick, ...rest }: LinkProps) {
  const isExternal = /^https?:|^mailto:|^#/.test(to)
  const handle = (e: MouseEvent<HTMLAnchorElement>) => {
    onClick?.(e)
    if (isExternal || e.metaKey || e.ctrlKey || e.defaultPrevented) return
    e.preventDefault()
    window.history.pushState({}, '', to)
    window.dispatchEvent(new PopStateEvent('popstate'))
    onNavigate?.()
  }
  return <a href={to} onClick={handle} {...rest} />
}
