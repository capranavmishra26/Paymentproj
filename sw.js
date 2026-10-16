// Offline cache for when the app is served over http(s) and installed from the browser.
// Network first, so a newer index.html / data.js is picked up whenever the server is reachable.
const CACHE = 'fund-projection-v3';
const FILES = ['./', 'index.html', 'data.js', 'manifest.webmanifest', 'lib/xlsx.bundle.js', 'lib/html2canvas.min.js', 'icons/icon-192.png', 'icons/icon-512.png'];

self.addEventListener('install', e => e.waitUntil(caches.open(CACHE).then(c => c.addAll(FILES)).then(() => self.skipWaiting())));
self.addEventListener('activate', e => e.waitUntil(
  caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim())
));
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  e.respondWith(
    fetch(e.request).then(res => { const copy = res.clone(); caches.open(CACHE).then(c => c.put(e.request, copy)); return res; })
      .catch(() => caches.match(e.request))
  );
});
