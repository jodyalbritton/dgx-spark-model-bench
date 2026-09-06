#!/usr/bin/env python3
"""Minimal Chrome DevTools screenshot driver (stdlib only).

usage: cdp_shoot.py <label> <outdir> [url]
Captures desktop light/dark, full page, mobile, and an 'after 11 s' shot that proves the
countdown ticks. Prints theme, socket state, countdown text and page height per shot.
"""
import base64, hashlib, json, os, socket, struct, subprocess, sys, time, urllib.request

CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
label, outdir = sys.argv[1], sys.argv[2]
URL = sys.argv[3] if len(sys.argv) > 3 else "http://127.0.0.1:4099/"
port = 9333
profile = os.path.join(os.environ.get("TMPDIR", "/tmp"), f"benchapp-cdp-profile-{label}")

class WS:
    def __init__(self, url):
        _, _, hostport, path = url.split("/", 3)
        host, p = hostport.split(":")
        self.s = socket.create_connection((host, int(p)))
        key = base64.b64encode(os.urandom(16)).decode()
        self.s.send((f"GET /{path} HTTP/1.1\r\nHost: {hostport}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n"
                     f"Sec-WebSocket-Key: {key}\r\nSec-WebSocket-Version: 13\r\n\r\n").encode())
        buf = b""
        while b"\r\n\r\n" not in buf: buf += self.s.recv(4096)
        self.buf = buf.split(b"\r\n\r\n", 1)[1]
        self.id = 0
    def send(self, method, params=None):
        self.id += 1
        data = json.dumps({"id": self.id, "method": method, "params": params or {}}).encode()
        mask = os.urandom(4)
        hdr = bytes([0x81])
        n = len(data)
        if n < 126: hdr += bytes([0x80 | n])
        elif n < 65536: hdr += bytes([0x80 | 126]) + struct.pack(">H", n)
        else: hdr += bytes([0x80 | 127]) + struct.pack(">Q", n)
        self.s.send(hdr + mask + bytes(b ^ mask[i % 4] for i, b in enumerate(data)))
        return self.id
    def _read(self, n):
        while len(self.buf) < n: self.buf += self.s.recv(1 << 20)
        out, self.buf = self.buf[:n], self.buf[n:]
        return out
    def recv(self):
        b0, b1 = self._read(2)
        n = b1 & 0x7F
        if n == 126: n = struct.unpack(">H", self._read(2))[0]
        elif n == 127: n = struct.unpack(">Q", self._read(8))[0]
        if b1 & 0x80: self._read(4)
        return json.loads(self._read(n))
    def call(self, method, params=None, timeout=60):
        i = self.send(method, params)
        t0 = time.time()
        while time.time() - t0 < timeout:
            m = self.recv()
            if m.get("id") == i: return m.get("result", m)
        raise TimeoutError(method)
    def wait_event(self, name, timeout=30):
        t0 = time.time()
        while time.time() - t0 < timeout:
            m = self.recv()
            if m.get("method") == name: return m
        raise TimeoutError(name)

proc = subprocess.Popen([CHROME, "--headless=new", "--disable-gpu", "--no-first-run", "--no-default-browser-check",
                         f"--remote-debugging-port={port}", f"--user-data-dir={profile}", "--window-size=1440,900", "about:blank"],
                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
try:
    for _ in range(50):
        try:
            targets = json.load(urllib.request.urlopen(f"http://127.0.0.1:{port}/json")); break
        except Exception: time.sleep(0.2)
    page = [t for t in targets if t["type"] == "page"][0]
    ws = WS(page["webSocketDebuggerUrl"])
    ws.call("Page.enable"); ws.call("Runtime.enable")

    def shoot(name, w, h, scheme, wait_s, full=False):
        ws.call("Emulation.setDeviceMetricsOverride", {"width": w, "height": h, "deviceScaleFactor": 1, "mobile": w < 500})
        ws.call("Emulation.setEmulatedMedia", {"features": [{"name": "prefers-color-scheme", "value": scheme}]})
        ws.call("Page.navigate", {"url": URL})
        ws.wait_event("Page.loadEventFired")
        time.sleep(wait_s)
        # read what the page shows right now
        r = ws.call("Runtime.evaluate", {"expression":
            "JSON.stringify({theme: document.documentElement.getAttribute('data-theme'), title: document.title,"
            " connected: !!document.querySelector('[data-phx-main].phx-connected'),"
            " countdown: (document.querySelector('#countdown-value, #countdown, [id*=countdown]')||{}).textContent,"
            " nav: !!document.querySelector('nav'), h: document.documentElement.scrollHeight})", "returnByValue": True})
        info = json.loads(r["result"]["value"])
        params = {"format": "png"}
        if full:
            params["captureBeyondViewport"] = True
            params["clip"] = {"x": 0, "y": 0, "width": w, "height": info["h"], "scale": 1}
        r = ws.call("Page.captureScreenshot", params, timeout=120)
        path = os.path.join(outdir, f"{label}-{name}.png")
        open(path, "wb").write(base64.b64decode(r["data"]))
        print(f"{name}: {os.path.getsize(path)} bytes | theme={info['theme']} connected={info['connected']} "
              f"countdown={ (info['countdown'] or '').strip()!r} nav={info['nav']} pageH={info['h']}", flush=True)

    shoot("desktop-light", 1440, 900, "light", 2)
    shoot("desktop-dark", 1440, 900, "dark", 2)
    shoot("full-light", 1440, 900, "light", 1, full=True)
    shoot("mobile-light", 390, 844, "light", 1)
    shoot("mobile-full-light", 390, 844, "light", 1, full=True)
    shoot("desktop-light-after-11s", 1440, 900, "light", 11)
finally:
    proc.terminate()
    try: proc.wait(5)
    except Exception: proc.kill()
