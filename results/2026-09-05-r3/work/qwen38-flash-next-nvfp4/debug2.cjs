const puppeteer = require("/tmp/pptest/node_modules/puppeteer-core")
const CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
const BASE = "http://localhost:4099"
const sleep = ms => new Promise(r => setTimeout(r, ms))

const run = async () => {
  const browser = await puppeteer.launch({executablePath: CHROME, headless: "new", args: ["--no-sandbox"]})
  const page = await browser.newPage()
  await page.setViewport({width: 1440, height: 950})

  const events = []
  await page.exposeFunction("logEvent", name => events.push(name))
  await page.evaluateOnNewDocument(() => {
    for (const ev of ["phx:submit", "submit", "phx-change"]) {
      document.addEventListener(ev, e => window.logEvent(`${ev} on ${e.target.tagName}#${e.target.id}`), true)
    }
  })

  await page.goto(BASE + "/", {waitUntil: "networkidle2"})
  await sleep(1200)

  await page.type("#signup-form input[type=email]", "not-an-email")
  await sleep(800)
  await page.click("#signup-submit")
  await sleep(1800)

  console.log("client events:", JSON.stringify(events))
  const info = await page.evaluate(() => ({
    form: document.getElementById("signup-form").outerHTML.slice(0, 900),
    after: document.getElementById("signup-form").nextElementSibling?.outerHTML.slice(0, 300),
    errorEls: [...document.querySelectorAll('[id^="signup-error"]')].map(e => e.id + "=" + e.textContent.trim()),
    alerts: [...document.querySelectorAll('[role="alert"]')].map(e => e.id + "|" + e.textContent.trim()),
    loading: document.querySelector(".phx-submit-loading")?.id ?? null,
  }))
  console.log("form html:", info.form)
  console.log("next sibling:", info.after)
  console.log("signup-error els:", JSON.stringify(info.errorEls))
  console.log("role=alert:", JSON.stringify(info.alerts))
  console.log("loading:", info.loading)

  await browser.close()
}
run().catch(e => { console.error(e); process.exit(2) })
