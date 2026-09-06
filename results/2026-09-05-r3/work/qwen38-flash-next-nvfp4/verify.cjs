const puppeteer = require("/tmp/pptest/node_modules/puppeteer-core")

const CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
const BASE = "http://localhost:4099"
const out = []
const log = (name, ok, extra = "") =>
  out.push(`${ok ? "PASS" : "FAIL"}  ${name}${extra ? " :: " + extra : ""}`)
const sleep = ms => new Promise(r => setTimeout(r, ms))

const run = async () => {
  const browser = await puppeteer.launch({
    executablePath: CHROME,
    headless: "new",
    args: ["--no-sandbox", "--disable-dev-shm-usage"],
  })

  // ------------------------------ desktop ------------------------------
  const page = await browser.newPage()
  await page.setViewport({width: 1440, height: 950})
  await page.goto(BASE + "/", {waitUntil: "networkidle2"})
  await sleep(1500)

  const ids = await page.evaluate(() => {
    const found = {}
    for (const id of ["main-nav", "nav-toggle", "theme-toggle", "countdown", "stats",
      "stat-signups", "stat-ticks", "signup-form", "signups", "activity"]) {
      found[id] = !!document.getElementById(id)
    }
    return found
  })
  log("desktop: every required id exists", Object.values(ids).every(Boolean), JSON.stringify(ids))

  const shape = await page.evaluate(() => ({
    emailInputs: document.querySelectorAll("#signup-form input[type=email]").length,
    formInputs: document.querySelectorAll("#signup-form input").length,
    novalidate: document.getElementById("signup-form").hasAttribute("novalidate"),
    activeLink: document.querySelector('#main-nav a[aria-current="page"]')?.getAttribute("href"),
    toggleHiddenAtDesktop: getComputedStyle(document.getElementById("nav-toggle")).display === "none",
    themeToggleVisible: getComputedStyle(document.getElementById("theme-toggle")).display !== "none",
    featureCards: document.querySelectorAll('#feature-grid [data-component="BenchappWeb.CompositeComponents.feature_card"]').length,
    activityLiOnly: [...document.getElementById("activity").children].every(n => n.tagName === "LI"),
  }))
  log("desktop: one email input, server-validated form, li-only feed",
    shape.emailInputs === 1 && shape.formInputs === 1 && shape.novalidate && shape.activityLiOnly,
    JSON.stringify(shape))
  log("desktop: nav marks Home current, desktop hides #nav-toggle",
    shape.activeLink === "/" && shape.toggleHiddenAtDesktop && shape.themeToggleVisible, JSON.stringify(shape))
  log("desktop: feature grid renders the registered composite", shape.featureCards === 6, `cards=${shape.featureCards}`)

  const first = await page.$eval("#countdown", el => el.textContent.trim())
  await sleep(11000)
  const later = await page.evaluate(() => ({
    countdown: document.getElementById("countdown").textContent.trim(),
    ticks: document.getElementById("stat-ticks-value").textContent.trim(),
    feed: document.querySelectorAll("#activity > li").length,
  }))
  log("desktop: countdown ticks down live, feed grows per tick",
    Number(later.countdown) < Number(first) && Number(later.ticks) >= 2 && later.feed >= 2,
    `${first} -> ${JSON.stringify(later)}`)

  // theme: two clicks must round-trip
  const before = await page.evaluate(() => document.documentElement.getAttribute("data-theme"))
  await page.click("#theme-toggle")
  await sleep(500)
  const afterOne = await page.evaluate(() => document.documentElement.getAttribute("data-theme"))
  await page.click("#theme-toggle")
  await sleep(500)
  const afterTwo = await page.evaluate(() => document.documentElement.getAttribute("data-theme"))
  log("desktop: #theme-toggle switches theme", before !== afterOne, `${before} -> ${afterOne}`)
  log("desktop: #theme-toggle switches back", afterTwo === before, `${afterOne} -> ${afterTwo}`)
  await page.screenshot({path: "/tmp/pptest/desktop-light.png"})

  await page.click("#theme-toggle")
  await sleep(500)
  await page.screenshot({path: "/tmp/pptest/desktop-dark.png"})

  // signup: invalid, valid, duplicate
  await page.type("#signup-form input[type=email]", "not-an-email")
  await page.click("#signup-submit")
  await sleep(1200)
  let state = await page.evaluate(() => ({
    error: document.getElementById("signup-error")?.textContent.replace(/\s+/g, " ").trim() ?? null,
    rows: document.querySelectorAll("#signups > li").length,
    signups: document.getElementById("stat-signups-value").textContent.trim(),
  }))
  log("desktop: invalid address shows #signup-error and adds nothing",
    !!state.error && state.rows === 0 && state.signups === "0", JSON.stringify(state))

  await page.$eval("#signup-form input[type=email]", el => (el.value = ""))
  await page.type("#signup-form input[type=email]", "ada@flightdeck.dev")
  await page.click("#signup-submit")
  await sleep(1200)
  state = await page.evaluate(() => ({
    error: !!document.getElementById("signup-error"),
    rows: document.querySelectorAll("#signups > li").length,
    newest: document.querySelector("#signups > li")?.textContent.replace(/\s+/g, " ").trim(),
    signups: document.getElementById("stat-signups-value").textContent.trim(),
    fieldCleared: document.querySelector("#signup-form input[type=email]").value === "",
    activityNewest: document.querySelector("#activity > li")?.textContent.replace(/\s+/g, " ").trim(),
  }))
  log("desktop: valid address lands in #signups, updates #stat-signups, clears the field",
    !state.error && state.rows === 1 && state.signups === "1" && state.fieldCleared &&
    state.newest.includes("ada@flightdeck.dev") && state.activityNewest.includes("ada@flightdeck.dev"),
    JSON.stringify(state))

  await page.$eval("#signup-form input[type=email]", el => (el.value = ""))
  await page.type("#signup-form input[type=email]", "ADA@flightdeck.dev")
  await page.click("#signup-submit")
  await sleep(1200)
  state = await page.evaluate(() => ({
    error: document.getElementById("signup-error")?.textContent.replace(/\s+/g, " ").trim() ?? null,
    rows: document.querySelectorAll("#signups > li").length,
    signups: document.getElementById("stat-signups-value").textContent.trim(),
  }))
  log("desktop: same address again is refused and stored once",
    !!state.error && state.rows === 1 && state.signups === "1", JSON.stringify(state))
  await page.screenshot({path: "/tmp/pptest/desktop-signup.png"})

  await page.click('#main-nav a[href="/about"]')
  await sleep(1500)
  const about = await page.evaluate(() => ({
    path: location.pathname,
    current: document.querySelector('#main-nav a[aria-current="page"]')?.getAttribute("href"),
    hasPage: !!document.getElementById("about-page"),
    cards: document.querySelectorAll('#about-stack [data-component="BenchappWeb.CompositeComponents.feature_card"]').length,
  }))
  log("desktop: nav reaches /about, marks it current, reuses the composite",
    about.path === "/about" && about.current === "/about" && about.hasPage && about.cards === 3,
    JSON.stringify(about))
  await page.screenshot({path: "/tmp/pptest/about-dark.png"})

  // /design and /custom-designs still work
  await page.goto(BASE + "/custom-designs", {waitUntil: "networkidle2"})
  await sleep(1200)
  const designs = await page.evaluate(() => ({
    featureCards: document.querySelectorAll('[data-component="BenchappWeb.CompositeComponents.feature_card"]').length,
    grids: document.querySelectorAll('[data-component="BenchappWeb.CompositeComponents.card_grid"]').length,
    text: document.body.innerText.includes("feature_card"),
  }))
  log("desktop: /custom-designs previews the registered composites",
    designs.featureCards >= 1 && designs.grids >= 1 && designs.text, JSON.stringify(designs))
  await page.screenshot({path: "/tmp/pptest/custom-designs.png"})

  await page.close()

  // ------------------------------- phone -------------------------------
  const phone = await browser.newPage()
  await phone.setViewport({width: 390, height: 844, isMobile: true, hasTouch: true})
  await phone.goto(BASE + "/", {waitUntil: "networkidle2"})
  await sleep(1500)

  const mob = await phone.evaluate(() => ({
    toggleVisible: getComputedStyle(document.getElementById("nav-toggle")).display !== "none",
    menuVisible: getComputedStyle(document.getElementById("nav-menu")).display !== "none",
    themeVisible: getComputedStyle(document.getElementById("theme-toggle")).display !== "none",
    countdown: document.getElementById("countdown").textContent.trim(),
    overflowX: document.documentElement.scrollWidth > window.innerWidth + 1,
  }))
  log("phone: toggle + theme control visible, menu collapsed, no horizontal overflow",
    mob.toggleVisible && !mob.menuVisible && mob.themeVisible && !mob.overflowX, JSON.stringify(mob))
  await phone.screenshot({path: "/tmp/pptest/phone-light.png"})

  await phone.click("#nav-toggle")
  await sleep(600)
  const opened = await phone.evaluate(() => ({
    visible: getComputedStyle(document.getElementById("nav-menu")).display !== "none",
    expanded: document.getElementById("nav-toggle").getAttribute("aria-expanded"),
    links: [...document.querySelectorAll("#nav-menu a")].map(a => a.getAttribute("href")),
  }))
  log("phone: #nav-toggle opens the menu with aria-expanded",
    opened.visible && opened.expanded === "true" && opened.links.length === 4, JSON.stringify(opened))
  await phone.screenshot({path: "/tmp/pptest/phone-menu.png"})

  await phone.click('#nav-menu a[href="/about"]')
  await sleep(1500)
  const phoneAbout = await phone.evaluate(() => ({
    path: location.pathname,
    current: document.querySelector('#main-nav a[aria-current="page"]')?.getAttribute("href"),
    overflowX: document.documentElement.scrollWidth > window.innerWidth + 1,
  }))
  log("phone: menu link navigates to /about and marks it current",
    phoneAbout.path === "/about" && phoneAbout.current === "/about" && !phoneAbout.overflowX,
    JSON.stringify(phoneAbout))
  await phone.screenshot({path: "/tmp/pptest/phone-about.png"})

  await phone.goto(BASE + "/", {waitUntil: "networkidle2"})
  await sleep(1200)
  const themeBefore = await phone.evaluate(() => document.documentElement.getAttribute("data-theme"))
  await phone.click("#theme-toggle")
  await sleep(500)
  const themeAfter = await phone.evaluate(() => document.documentElement.getAttribute("data-theme"))
  log("phone: theme toggle usable at phone width", themeBefore !== themeAfter, `${themeBefore} -> ${themeAfter}`)
  await phone.screenshot({path: "/tmp/pptest/phone-dark.png"})

  await phone.type("#signup-form input[type=email]", "grace@flightdeck.dev")
  await phone.click("#signup-submit")
  await sleep(1200)
  const phoneSignup = await phone.evaluate(() => ({
    rows: document.querySelectorAll("#signups > li").length,
    signups: document.getElementById("stat-signups-value").textContent.trim(),
    activity: document.querySelectorAll("#activity > li").length,
    overflowX: document.documentElement.scrollWidth > window.innerWidth + 1,
  }))
  log("phone: signup works at phone width without overflow",
    phoneSignup.rows === 1 && phoneSignup.signups === "1" && phoneSignup.activity >= 1 && !phoneSignup.overflowX,
    JSON.stringify(phoneSignup))
  await phone.evaluate(() => document.getElementById("signup-form").scrollIntoView())
  await sleep(400)
  await phone.screenshot({path: "/tmp/pptest/phone-signup.png"})

  await phone.close()
  await browser.close()

  console.log(out.join("\n"))
  const failures = out.filter(l => l.startsWith("FAIL")).length
  console.log(`\n${out.length - failures}/${out.length} checks passed`)
  process.exit(failures ? 1 : 0)
}

run().catch(err => {
  console.error(err)
  console.log(out.join("\n"))
  process.exit(2)
})
