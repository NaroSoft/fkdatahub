'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"apple-touch-icon.png": "70ef9dd7ccd5ec112dbc95939ad33912",
"assets/AssetManifest.bin": "2834b9b204bba81be19e8afd5fa25a8a",
"assets/AssetManifest.bin.json": "6fcb4048e486547c31c427e995edc726",
"assets/AssetManifest.json": "e590db8ce85ef64a548894fadbe1866c",
"assets/assets/agent.jpg": "1361f6c0c7a2f20a0e376940d023cf89",
"assets/assets/airtel1.jpeg": "bcc209d3db6a0199db524f5c2f199863",
"assets/assets/airtel2.jpeg": "10d69e65984a426dfb14f0e410b75ad4",
"assets/assets/airtel2.jpg": "8fb3cb8f9f8eef2a343265f4efa5891e",
"assets/assets/airtime.png": "b8e549737d5b115d3ef68be6844b8d08",
"assets/assets/allone.jpg": "0169c47a19e06b5ef0f5a5c55ddb9ff5",
"assets/assets/bundle.jpg": "ad79e3084fd3edd52f931ebe25d695ca",
"assets/assets/buydata.jpg": "130aa60c296626632e4b232d57352559",
"assets/assets/celeb.gif": "0954dfdb9a345b7a4c6360e85fa3f28d",
"assets/assets/data.jpg": "80141cb4cc996bbcbc63f479661e6ec7",
"assets/assets/FKDataHub.png": "06b4228e7783b51abef8da87d2f40118",
"assets/assets/FKDataHub1.png": "a72c7959fb91cbe76e129ccc53088a70",
"assets/assets/FKDataHub2.png": "00de4eca34749fe9cddacc116b95fd45",
"assets/assets/joy.png": "82e0154b9e8f5544145649a9b4797d6f",
"assets/assets/loading_gif.gif": "4e51b074e44580776aac5e7679d9f7af",
"assets/assets/loading_gif.json": "02775f78daae067bb77cc32b1e4396ca",
"assets/assets/mtn1.png": "4b4acf291035dcdec6a6336dac159e36",
"assets/assets/mtnafa.jpeg": "ffb9728a9781bc37c42338f670cfc628",
"assets/assets/order.jpg": "6646d5a9302b09464977e5dd435b2276",
"assets/assets/order1.png": "a4f5ef0df24ef4d5be1ed25942763007",
"assets/assets/process.gif": "72d13dd3b4b60dc43bcd7a351acc408c",
"assets/assets/pwait.gif": "e51865527b961a9d5ad79e67dd6bbb79",
"assets/assets/shop.png": "de2befcffb963c56ae0d0bc9bbfdf4b2",
"assets/assets/speak.png": "6fb48932c77d2c237495d94934bab8ad",
"assets/assets/support.png": "f9c2814fcf5687c3da471aa3ba1428fa",
"assets/assets/telecel1.png": "f055d0fa0b774e919adabf9971b07a26",
"assets/assets/wait.gif": "96f5e8322afd4d6a9da7caaa2eb9af08",
"assets/assets/wal2.jpg": "123f874cea3271b63124f106fbb71cfd",
"assets/assets/walp1.jpg": "f8258ace722ad38b636e88c0cfd66e17",
"assets/assets/whatsapp.png": "4e9c614061dc9a0f685cff77b160bb8e",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "243d6d6c95635f51c7a73b033030ffe1",
"assets/NOTICES": "2c76fa346c4213473856946aa1ecea2d",
"assets/packages/carousel_custom_slider/assets/placeholder.png": "248a3f7ab1e31945e9d3e67cea0240a8",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.ico": "59974a1849a22a1ecf59ba45dace1207",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"firebase-service-worker.js": "5b9714fa6aae136f9f1a7047d3361cba",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"flutter_bootstrap.js": "0c5e719fd71a266e3a2e5238626aa59b",
"icon-192-maskable.png": "4363cf7e7a9bb11e2dba67d094243632",
"icon-192.png": "1f8ccaf4e917194b61178d547acb9cea",
"icon-512-maskable.png": "28db86b7da3ee2c4a169193c341a2936",
"icon-512.png": "55a95c9a79459d25e7902cc5062a51bf",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "8d1ba99ec9ab87550268aefdf17f1fdb",
"/": "8d1ba99ec9ab87550268aefdf17f1fdb",
"js_interop.dart": "ae89a932b30503722c95a2738ba58650",
"main.dart.js": "b772755bcd98796e72b21ba3118c85a3",
"manifest.json": "1ed4c2b2655581209e3f3c9003329c29",
"offline.html": "eb2579b35e4ec0bcf9e0109c6cc338cf",
"sw.js": "a9f7b48ffe88e10026996f0090623d9e",
"version.json": "81b41f1a3a854532c53dfa978ff102f3"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
