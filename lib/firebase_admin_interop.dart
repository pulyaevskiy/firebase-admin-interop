// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// Firebase Admin Interop Library for Dart.
///
/// This is a JS interop library so it can't be used standalone. It must be
/// compiled to JavaScript as a valid Node module and import official Node.js
/// Admin SDK for Firebase.
///
/// Main entry point to this library is [FirebaseAdmin] class. It is a higher
/// level interface on top of JS bindings which abstracts away some details
/// of interacting with JavaScript and Node.js APIs.
///
/// It is still possible to use JS bindings directly by importing "js.dart":
///
///     import 'package:firebase_admin_interop/js.dart';
///
/// Below is a quick start example of working with the Realtime Database API:
///
///     import 'dart:async';
///     import 'package:firebase_admin_interop/firebase_admin_interop.dart';
///
///     Future main() async {
///       var admin = FirebaseAdmin.instance;
///       var cert = admin.certFromPath(serviceAccountKeyFilename);
///       var app = admin.initializeApp(new AppOptions(
///         credential: cert,
///         databaseUrl: "YOUR_DB_URL",
///       ));
///       var ref = app.database().ref('/test-path');
///       // Write value to the database at "/test-path" location.
///       await ref.setValue("Hello world");
///       // Read value from the same database location.
///       var snapshot = ref.once("value");
///       print(snapshot.val());
///     }
///
/// See also:
///   * [FirebaseAdmin]
///   * [Auth]
///   * [App]
///   * [Database]
///   * [Firestore]
library firebase_admin_interop;

export 'src/admin.dart';
export 'src/app.dart';
export 'src/auth.dart';
export 'src/bindings.dart' show AppOptions, SetOptions, FirestoreSettings;
export 'src/database.dart';
export 'src/firestore.dart';
export 'src/messaging.dart';
