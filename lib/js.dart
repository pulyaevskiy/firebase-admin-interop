// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// Dart facade for Firebase Admin NodeJS library.
///
/// Make sure to call [initFirebaseAdmin] before using any other functionality
/// of this library:
///
///     import 'package:firebase_admin_interop/js.dart' as admin;
///     import 'package:node_interop/node_interop.dart';
///
///     void main() {
///       admin.initFirebaseAdmin();
///       admin.App app = admin.initializeApp(jsify({
///         'projectId': '<YOUR_PROJECT_ID>', // etc.
///       }));
///       console.log(app);
///     }
library firebase_admin_interop.js;

export 'src/bindings.dart';
