import { Nav } from './components/Nav'
import { Landing } from './pages/Landing'
import { Features } from './pages/Features'
import { About } from './pages/About'
import { useTheme } from './lib/useTheme'
import { useRoute } from './lib/router'
import './App.css'

function App() {
  const { theme, toggle } = useTheme()
  const { path } = useRoute()

  let page = <Landing />
  if (path === '/about') page = <About />
  else if (path === '/features') page = <Features />

  return (
    <>
      <Nav path={path} theme={theme} onToggleTheme={toggle} />
      <main>{page}</main>
      <footer className="footer">
        Pulse — launch pages that feel alive. © {new Date().getFullYear()}
      </footer>
    </>
  )
}

export default App
