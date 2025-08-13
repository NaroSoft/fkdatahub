// js_interop.dart
@JS()
library js_interop;

import 'package:js/js.dart';

// Allows calling the applyUpdate() function from JavaScript
@JS('applyUpdate')
external void applyUpdate();

// Allows checking if the service worker is ready
@JS('navigator.serviceWorker.ready')
external Future<dynamic> get serviceWorkerReady;