// Configuration
const CACHE_PREFIX = 'my-app-cache-';
const DYNAMIC_CACHE = 'dynamic-cache-v1';
const OFFLINE_PAGE = '/offline.html';

// Install event - cache core assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    fetch('/version.json')
      .then(response => response.json())
      .then(versionInfo => {
        const CACHE_NAME = versionInfo.cache_name || CACHE_PREFIX + 'v1';
        return caches.open(CACHE_NAME).then((cache) => {
          return cache.addAll([
            '/',
            '/main.dart.js',
            '/flutter.js',
            '/manifest.json',
            '/favicon.ico',
            // Add other critical assets
          ]);
        });
      })
  );
});

// Activate event - clean old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (!cacheName.startsWith(CACHE_PREFIX) || 
              cacheName === DYNAMIC_CACHE) {
            return;
          }
          return caches.delete(cacheName);
        })
      );
    })
  );
});

// Fetch event - network first with cache fallback
self.addEventListener('fetch', (event) => {
  event.respondWith(
    fetch(event.request)
      .then((response) => {
        // If we got a response, cache it
        if (event.request.method === 'GET') {
          const responseToCache = response.clone();
          caches.open(DYNAMIC_CACHE).then((cache) => {
            cache.put(event.request, responseToCache);
          });
        }
        return response;
      })
      .catch(() => {
        // Network failed, try cache
        return caches.match(event.request)
          .then((response) => {
            return response || caches.match(OFFLINE_PAGE);
          });
      })
  );
});

// Listen for messages from the app
self.addEventListener('message', (event) => {
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
  }
});