// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:meta/meta.dart';
import 'package:node_interop/node_interop.dart';

import 'bindings.dart' as js;
import 'database.dart';

const kDefaultAppName = '[DEFAULT]';

/// Provides access to Firebase Admin APIs.
///
/// To start using Firebase services initialize a Firebase application
/// with [initializeApp] method.
class FirebaseAdmin {
  final js.FirebaseAdmin _inner;
  FirebaseAdmin._(this._inner);

  factory FirebaseAdmin() => new FirebaseAdmin._(js.requireFirebaseAdmin());

  final Map<String, App> _apps = new Map();

  /// Creates and initializes a Firebase [App] instance.
  ///
  /// The app is initialized with provided `credential` and `databaseURL`.
  /// A valid credential can be obtained from [CredentialService.cert] or
  /// [CredentialService.certFromPath].
  ///
  /// The `name` argument allows using multiple Firebase applications at the same
  /// time. If omitted then default app name is used.
  ///
  /// Example:
  ///
  ///     var admin = new FirebaseAdmin();
  ///     var app = admin.initializeApp(
  ///       credential: admin.credential.cert(
  ///         projectId: 'your-project-id',
  ///         clientEmail: 'your-client-email',
  ///         privateKey: 'your-private-key',
  ///       ),
  ///       databaseURL: 'https://your-database.firebase.io',
  ///     );
  ///
  /// See also:
  ///   * [App]
  ///   * [CredentialService.cert]
  ///   * [CredentialService.certFromPath]
  App initializeApp({
    @required js.Credential credential,
    @required String databaseURL,
    String name: kDefaultAppName,
  }) {
    if (_apps.containsKey(name)) return _apps[name];

    var jsOptions = new js.AppOptions(
      credential: credential,
      databaseURL: databaseURL,
    );
    _apps[name] = new App._(_inner.initializeApp(jsOptions, name));
    return _apps[name];
  }

  /// Credential service of this admin instance.
  CredentialService get credential =>
      _credential ??= new CredentialService._(_inner.credential);
  CredentialService _credential;

  /// Returns the [Database] service associated with default [App] when called
  /// without arguments. Otherwise returns [Database] service of specified
  /// [App] instance.
  Database database([App app]) {
    app ??= _apps[kDefaultAppName];
    assert(app != null);
    return app.database();
  }
}

/// Represents initialized Firebase application and provides access to the
/// app's services.
class App {
  final js.App _inner;

  App._(this._inner);

  /// The name of this application.
  String get name => _inner.name;

  /// Returns [Database] service for this application.
  Database database() => _database ??= new Database(_inner.database());
  Database _database;

  /// Renders this app unusable and frees the resources of all associated
  /// services.
  Future<Null> delete() => jsPromiseToFuture(_inner.delete());
}

/// Firebase Admin credential service.
class CredentialService {
  final js.CredentialService _inner;

  CredentialService._(this._inner);

  /// Creates app certificate from service account key parameters.
  js.Credential cert({
    String projectId,
    String clientEmail,
    String privateKey,
  }) {
    return _inner.cert(new js.ServiceAccountConfig(
      project_id: projectId,
      client_email: clientEmail,
      private_key: privateKey,
    ));
  }

  /// Creates app certificate from service account key file specified by `path`.
  js.Credential certFromPath(String path) => _inner.cert(path);
}
