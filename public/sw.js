/* ====================================================
   Ronda Service Worker v1.0
   Aggressive caching for offline play
   ==================================================== */

const CACHE_VERSION = 'ronda-v1.0.0';
const STATIC_CACHE  = `${CACHE_VERSION}-static`;
const RUNTIME_CACHE = `${CACHE_VERSION}-runtime`;

const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/manifest.json'
];

// Install: cache static assets
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(STATIC_CACHE).then(cache => {
      return cache.addAll(STATIC_ASSETS);
    }).then(() => self.skipWaiting())
  );
});

// Activate: clean old caches
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys
          .filter(key => key.startsWith('ronda-') && key !== STATIC_CACHE && key !== RUNTIME_CACHE)
          .map(key => caches.delete(key))
      )
    ).then(() => self.clients.claim())
  );
});

// Fetch: network-first for API, cache-first for assets
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);

  // Skip non-GET, Supabase, Firebase, Ably (real-time must be live)
  if (event.request.method !== 'GET') return;
  if (url.hostname.includes('supabase.co')) return;
  if (url.hostname.includes('firebaseio.com')) return;
  if (url.hostname.includes('ably.io') || url.hostname.includes('realtime.ably.io')) return;
  if (url.hostname.includes('pubnub.com')) return;
  if (url.hostname.includes('paypal.com')) return;

  // Cache-first for same-origin static assets (fonts, icons, etc.)
  if (url.origin === self.location.origin) {
    event.respondWith(
      caches.match(event.request).then(cached => {
        if (cached) return cached;
        return fetch(event.request).then(response => {
          if (response.status === 200) {
            const clone = response.clone();
            caches.open(RUNTIME_CACHE).then(cache => cache.put(event.request, clone));
          }
          return response;
        }).catch(() => {
          // Offline fallback: return index.html for navigation
          if (event.request.mode === 'navigate') {
            return caches.match('/index.html');
          }
        });
      })
    );
    return;
  }

  // For external CDN assets (Google Fonts, etc.) — cache-first
  if (url.hostname.includes('fonts.googleapis.com') ||
      url.hostname.includes('fonts.gstatic.com') ||
      url.hostname.includes('cdnjs.cloudflare.com')) {
    event.respondWith(
      caches.match(event.request).then(cached => {
        if (cached) return cached;
        return fetch(event.request).then(response => {
          const clone = response.clone();
          caches.open(RUNTIME_CACHE).then(cache => cache.put(event.request, clone));
          return response;
        });
      })
    );
  }
});

// Background sync for score updates
self.addEventListener('sync', event => {
  if (event.tag === 'sync-scores') {
    console.log('[SW] Background sync: scores');
  }
});

// Push notifications (future)
self.addEventListener('push', event => {
  const data = event.data?.json() || {};
  const options = {
    body: data.body || 'روندة تنتظرك!',
    icon: '/icons/icon-192.png',
    badge: '/icons/icon-96.png',
    vibrate: [200, 100, 200],
    data: { url: data.url || '/' },
    actions: [
      { action: 'play',   title: 'العب الآن' },
      { action: 'close',  title: 'لاحقاً' }
    ],
    dir: 'rtl',
    lang: 'ar'
  };
  event.waitUntil(
    self.registration.showNotification(data.title || 'روندة', options)
  );
});

self.addEventListener('notificationclick', event => {
  event.notification.close();
  if (event.action === 'play') {
    event.waitUntil(clients.openWindow('/'));
  }
});
