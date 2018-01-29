// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:node_interop/util.dart';

import 'admin.dart';
import 'bindings.dart' as js;
import 'database.dart';
import 'firestore.dart';

/// Represents initialized Firebase application and provides access to the
/// app's services.
class App {
  final js.App nativeInstance;

  App(this.nativeInstance);

  /// The name of this application.
  String get name => nativeInstance.name;

  /// The (read-only) configuration options for this app. These are the original
  /// parameters given in [FirebaseAdmin.initializeApp].
  js.AppOptions get options => nativeInstance.options;

  /// Returns Realtime [Database] client for this application.
  Database database() => _database ??= new Database.forApp(this);
  Database _database;

  /// Returns [Firestore] client for this application.
  Firestore firestore() => _firestore ??= new Firestore.forApp(this);
  Firestore _firestore;

  /// Renders this app unusable and frees the resources of all associated
  /// services.
  Future<Null> delete() => promiseToFuture(nativeInstance.delete());
}
