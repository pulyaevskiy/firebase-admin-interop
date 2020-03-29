// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:node_interop/util.dart';

import 'admin.dart';
import 'auth.dart';
import 'bindings.dart' as js;
import 'database.dart';
import 'firestore.dart';
import 'messaging.dart';

/// Represents initialized Firebase application and provides access to the
/// app's services.
class App {
  App(this.nativeInstance);

  @protected
  final js.App nativeInstance;

  /// The name of this application.
  String get name => nativeInstance.name;

  /// The (read-only) configuration options for this app. These are the original
  /// parameters given in [FirebaseAdmin.initializeApp].
  js.AppOptions get options => nativeInstance.options;

  /// Gets the [Auth] service for this application.
  Auth auth() => _auth ??= new Auth(nativeInstance.auth());
  Auth _auth;

  /// Gets Realtime [Database] client for this application.
  Database database() =>
      _database ??= new Database(this.nativeInstance.database(), this);
  Database _database;

  /// Gets [Firestore] client for this application.
  Firestore firestore() =>
      _firestore ??= new Firestore(nativeInstance.firestore());
  Firestore _firestore;

  /// Gets [Messaging] client for this application.
  Messaging messaging() =>
      _messaging ??= new Messaging(nativeInstance.messaging());
  Messaging _messaging;

  /// Renders this app unusable and frees the resources of all associated
  /// services.
  Future<void> delete() => promiseToFuture<void>(nativeInstance.delete());
}
