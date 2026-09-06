const puppeteer = require("/tmp/pptest/node_modules/puppeteer-core")
const CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
const DIR = "/Users/jody/dgx-spark-model-bench/results/2026-09-05-r3/work/qwen38-flash-next-nvfp4/shots/"
const sleep = ms => new Promise(r => setTimeout(r, ms))

const shoot = async (browser, {theme, width, height, path, url, scroll = 0, menu = false}) => {
  const page = await browser.newPage()
  await page.evaluateOnNewDocument(t => localStorage.setItem("phx:theme", t), theme)
  await page.setViewport({width, height, isMobile: width < 700, hasTouch: width < 700})
  await page.goto(url, {waitUntil: "networkidle2"})
  await sleep(1400)
  if (menu) {
    await page.click("#nav-toggle")
    await sleep(600)
  }
  if (scroll) {
    await page.evaluate(y => window.scrollTo(0, y), scroll)
    await sleep(500)
  }
  const actual = await page.evaluate(() => document.documentElement.getAttribute("data-theme"))
  await page.screenshot({path: DIR + path})
  await page.close()
  return `${path} theme=${actual}`
}

const run = async () => {
  const browser = await puppeteer.launch({executablePath: CHROME, headless: "new", args: ["--no-sandbox"]})
  const base = "http://localhost:4099"
  const done = []
  done.push(await shoot(browser, {theme: "light", width: 1440, height: 950, path: "light-home-top.png", url: base + "/"}))
  done.push(await shoot(browser, {theme: "light", width: 1440, height: 950, path: "light-home-board.png", url: base + "/", scroll: 780}))
  done.push(await shoot(browser, {theme: "light", width: 1440, height: 950, path: "light-home-features.png", url: base + "/", scroll: 1750}))
  done.push(await shoot(browser, {theme: "light", width: 1440, height: 950, path: "light-about.png", url: base + "/about"}))
  done.push(await shoot(browser, {theme: "light", width: 390, height: 844, path: "light-phone-top.png", url: base + "/"}))
  done.push(await shoot(browser, {theme: "light", width: 390, height: 844, path: "light-phone-menu.png", url: base + "/", menu: true}))
  done.push(await shoot(browser, {theme: "light", width: 390, height: 844, path: "light-phone-board.png", url: base + "/", scroll: 900}))
  done.push(await shoot(browser, {theme: "dark", width: 390, height: 844, path: "dark-phone-board.png", url: base + "/", scroll: 900}))
  await browser.close()
  console.log(done.join("\n"))
}
run().catch(e => { console.error(e); process.exit(2) })
