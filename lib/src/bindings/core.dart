// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

@JS()
library firebase_admin_interop.bindings.core;

import 'package:js/js.dart';
import 'package:node_interop/node_interop.dart';

import 'database.dart';

@JS()
abstract class JsApp {
  external String get name;
  external JsDatabase database();
  external Promise delete();
}

@JS()
abstract class JsAppOptions {
  external JsCredential get credential;
  external String get databaseURL;
  external factory JsAppOptions({JsCredential credential, String databaseURL});
}

@JS()
abstract class JsCredential {
  external JsAccessToken getAccessToken();
  // TODO: Is there a way to model below methods as static, as described in Node API docs?
  external JsCredential applicationDefault();
  external JsCredential cert(serviceAccountPathOrObject);
  external JsCredential refreshToken(refreshTokenPathOrObject);
}

@JS()
abstract class JsAccessToken {
  external String get access_token;
  external num get expires_in;
}
