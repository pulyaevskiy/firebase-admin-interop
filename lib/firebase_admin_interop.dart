// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// Firebase Admin Interop Library for Dart.
///
/// This is a JS interop library so it can't be used standalone and must be
/// compiled to JavaScript as a valid Node module which imports official JS
/// Admin SDK for Firebase.
///
/// Main entry point to this library is [FirebaseAdmin] class. Create an instance
/// of this class to access all available admin APIs.
///
///     import 'package:firebase_admin_interop/firebase_admin_interop.dart';
///
///     void main() {
///       var admin = new FirebaseAdmin();
///       admin.initializeApp(options);
///       // ...
///     }
///
/// See also:
///   * [FirebaseAdmin]
library firebase_admin_interop;

export 'src/admin.dart';
export 'src/database.dart';
