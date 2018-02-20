// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// Dart facade for Firebase Admin Node.js library.
///
///     import 'package:firebase_admin_interop/js.dart';
///     import 'package:node_interop/node.dart';
///
///     void main() {
///       FirebaseAdmin admin = require('firebase-admin');
///       App app = admin.initializeApp(jsify({
///         'projectId': '<YOUR_PROJECT_ID>', // etc.
///       }));
///       console.log(app);
///     }
library firebase_admin_interop.js;

export 'src/bindings.dart';
