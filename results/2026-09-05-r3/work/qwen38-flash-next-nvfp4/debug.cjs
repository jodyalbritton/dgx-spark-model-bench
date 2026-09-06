const puppeteer = require("/tmp/pptest/node_modules/puppeteer-core")
const CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
const BASE = "http://localhost:4099"
const sleep = ms => new Promise(r => setTimeout(r, ms))

const run = async () => {
  const browser = await puppeteer.launch({executablePath: CHROME, headless: "new", args: ["--no-sandbox"]})
  const page = await browser.newPage()
  await page.setViewport({width: 1440, height: 950})

  // A: theme toggle double-click on /about (no timers on that page)
  await page.goto(BASE + "/about", {waitUntil: "networkidle2"})
  await sleep(1000)
  const read = () => page.evaluate(() => ({
    theme: document.documentElement.getAttribute("data-theme"),
    src: document.documentElement.getAttribute("data-theme-source"),
    stored: localStorage.getItem("phx:theme"),
    hooks: document.querySelectorAll("[phx-hook]").length,
    ds: document.getElementById("theme-toggle").dataset.phxTheme || null,
  }))
  console.log("initial   ", JSON.stringify(await read()))
  await page.click("#theme-toggle")
  await sleep(400)
  console.log("click 1   ", JSON.stringify(await read()))
  await page.click("#theme-toggle")
  await sleep(400)
  console.log("click 2   ", JSON.stringify(await read()))
  await page.click("#theme-toggle")
  await sleep(400)
  console.log("click 3   ", JSON.stringify(await read()))
  // click the inner button directly
  await page.click("#theme-toggle button")
  await sleep(400)
  console.log("inner btn ", JSON.stringify(await read()))

  // B: invalid submit on a fresh home page
  const page2 = await browser.newPage()
  await page2.setViewport({width: 1440, height: 950})
  await page2.goto(BASE + "/", {waitUntil: "networkidle2"})
  await sleep(1500)
  await page2.type("#signup-form input[type=email]", "not-an-email")
  await sleep(600)
  console.log("after type", JSON.stringify(await page2.evaluate(() => ({
    value: document.querySelector("#signup-form input[type=email]").value,
    error: !!document.getElementById("signup-error"),
  }))))
  await page2.click("#signup-submit")
  for (const ms of [400, 1200, 2500]) {
    await sleep(ms)
    console.log(`submit +${ms}ms`, JSON.stringify(await page2.evaluate(() => ({
      hasError: !!document.getElementById("signup-error"),
      error: document.getElementById("signup-error")?.textContent.trim() ?? null,
      rows: document.querySelectorAll("#signups > li").length,
      signups: document.getElementById("stat-signups-value").textContent.trim(),
      invalid: document.querySelector("#signup-form input[type=email]")?.getAttribute("aria-invalid"),
    }))))
  }

  // C: blank submit
  await page2.$eval("#signup-form input[type=email]", el => (el.value = ""))
  await page2.type("#signup-form input[type=email]", " ")
  await page2.click("#signup-submit")
  await sleep(1500)
  console.log("blank     ", JSON.stringify(await page2.evaluate(() => ({
    hasError: !!document.getElementById("signup-error"),
    error: document.getElementById("signup-error")?.textContent.trim() ?? null,
  }))))

  await browser.close()
}
run().catch(e => { console.error(e); process.exit(2) })
