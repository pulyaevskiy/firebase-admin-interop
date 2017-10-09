// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
@JS()
library firebase_admin_interop.bindings.admin;

import 'package:js/js.dart';
import 'package:node_interop/node_interop.dart';

import 'core.dart';
import 'database.dart';

JsFirebaseAdmin requireFirebaseAdmin() => require('firebase-admin');

@JS()
abstract class JsFirebaseAdmin {
  external static String get SDK_VERSION;
  external JsCredential get credential;
  external JsApp app([String name]);
  external JsApp initializeApp(options, [String name]);
  external JsDatabase database([app]);
}

@JS()
@anonymous
abstract class JsServiceAccountConfig {
  external String get project_id;
  external String get client_email;
  external String get private_key;

  external factory JsServiceAccountConfig(
      {String project_id, String client_email, String private_key});
}
