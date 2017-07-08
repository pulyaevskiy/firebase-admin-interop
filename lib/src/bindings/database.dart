// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

@JS()
library firebase_admin_interop.bindings.database;

import 'package:js/js.dart';
import 'core.dart';
import 'package:node_interop/node_interop.dart';

@JS()
@anonymous
abstract class JsDatabase {
  external JsApp get app;
  // Static members
  external JsServerValue get ServerValue;
  external enableLogging([bool logger, bool persistent]);
  // Public members
  external goOffline();
  external goOnline();
  external JsReference ref([String path]);
  external JsReference refFromURL(String url);
}

@JS()
@anonymous
abstract class JsServerValue {
  external num get TIMESTAMP;
}

@JS()
@anonymous
abstract class JsReference {
  external String get key;
  external JsReference get parent;
  external JsReference get root;
  external JsReference child(String path);
  external JsPromise once(String eventType,
      [successCallback, failureCallbackOrContext, context]);
  external JsPromise set(value, [onComplete]);
}

@JS()
@anonymous
abstract class JsDataSnapshot {
  external String get key;
  external JsReference get ref;
  external JsDataSnapshot child(String path);
  external bool exists();
  external dynamic exportVal();
  external bool forEach(bool action(JsDataSnapshot child));
  external dynamic getPriority(); // string, number or null #duh
  external bool hasChild(String path);
  external bool hasChildren();
  external int numChildren();
  external dynamic val();
}
