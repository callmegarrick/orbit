/* Orbit service worker — offline shell + best-effort daily background check */
const VERSION = "orbit-v4";
const SHELL = ["./", "./index.html", "./manifest.json", "./icon.svg", "./icon-192.png", "./icon-512.png"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(VERSION).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});
self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== VERSION && k !== "orbit-fonts").map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", e => {
  const url = new URL(e.request.url);
  // Google Fonts: stale-while-revalidate into a separate cache so the app is pretty offline
  if (url.hostname.includes("fonts.googleapis.com") || url.hostname.includes("fonts.gstatic.com")) {
    e.respondWith(
      caches.open("orbit-fonts").then(async c => {
        const hit = await c.match(e.request);
        const net = fetch(e.request).then(r => { if (r.ok) c.put(e.request, r.clone()); return r; }).catch(() => hit);
        return hit || net;
      })
    );
    return;
  }
  if (url.origin !== location.origin) return;
  // App shell: cache-first with background refresh — works even when the local server is off
  e.respondWith(
    caches.open(VERSION).then(async c => {
      const hit = await c.match(e.request, { ignoreSearch: true });
      const net = fetch(e.request).then(r => { if (r.ok) c.put(e.request, r.clone()); return r; }).catch(() => hit);
      return hit || net;
    })
  );
});

/* ---- background daily check (fires when installed as a PWA and the browser is running) ---- */
function idbGet(key) {
  return new Promise((res, rej) => {
    const rq = indexedDB.open("orbit-idb", 1);
    rq.onupgradeneeded = () => rq.result.createObjectStore("kv");
    rq.onsuccess = () => {
      const db = rq.result;
      const g = db.transaction("kv").objectStore("kv").get(key);
      g.onsuccess = () => { res(g.result); db.close(); };
      g.onerror = () => { rej(g.error); db.close(); };
    };
    rq.onerror = () => rej(rq.error);
  });
}
function idbPut(key, val) {
  return new Promise((res, rej) => {
    const rq = indexedDB.open("orbit-idb", 1);
    rq.onupgradeneeded = () => rq.result.createObjectStore("kv");
    rq.onsuccess = () => {
      const db = rq.result;
      const tx = db.transaction("kv", "readwrite");
      tx.objectStore("kv").put(val, key);
      tx.oncomplete = () => { res(); db.close(); };
      tx.onerror = () => { rej(tx.error); db.close(); };
    };
    rq.onerror = () => rej(rq.error);
  });
}
async function dailyCheck() {
  try {
    const today = new Date();
    const iso = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, "0")}-${String(today.getDate()).padStart(2, "0")}`;
    const lastShown = await idbGet("last-shown");
    if (lastShown === iso) return;
    const alerts = (await idbGet("alerts")) || [];
    const due = alerts.filter(a => a.date <= iso);
    if (!due.length) return;
    await idbPut("last-shown", iso);
    await self.registration.showNotification("Orbit — time to reach out", {
      body: due[due.length - 1].text,
      icon: "icon.svg",
      badge: "icon.svg",
      tag: "orbit-daily",
    });
  } catch (e) { /* best-effort */ }
}
self.addEventListener("periodicsync", e => { if (e.tag === "orbit-daily") e.waitUntil(dailyCheck()); });
self.addEventListener("message", e => { if (e.data === "check-alerts") e.waitUntil(dailyCheck()); });

self.addEventListener("notificationclick", e => {
  e.notification.close();
  e.waitUntil(
    self.clients.matchAll({ type: "window", includeUncontrolled: true }).then(list => {
      const client = list.find(c => c.url.includes(self.registration.scope));
      return client ? client.focus() : self.clients.openWindow("./");
    })
  );
});
