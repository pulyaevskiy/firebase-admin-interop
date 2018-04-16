// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'app.dart';
import 'bindings.dart' as js;

/// Provides access to Firebase Admin APIs.
///
/// To start using Firebase services initialize a Firebase application
/// with [initializeApp] method.
class FirebaseAdmin {
  final js.FirebaseAdmin _admin;
  final Map<String, App> _apps = new Map();

  static FirebaseAdmin get instance => _instance ??= new FirebaseAdmin._();
  static FirebaseAdmin _instance;

  FirebaseAdmin._() : _admin = js.admin;

  ///
  /// Creates and initializes a Firebase [App] instance with the given
  /// [options] and [name].
  ///
  /// The options is initialized with provided `credential` and `databaseURL`.
  /// A valid credential can be obtained with [cert] or
  /// [certFromPath].
  ///
  /// The [name] argument allows using multiple Firebase applications at the same
  /// time. If omitted then default app name is used.
  ///
  /// Example:
  ///
  ///     var certificate = FirebaseAdmin.instance.cert(
  ///       projectId: 'your-project-id',
  ///       clientEmail: 'your-client-email',
  ///       privateKey: 'your-private-key',
  ///     );
  ///     var app = FirebaseAdmin.instance.initializeApp(
  ///       new AppOptions(
  ///         credential: certificate,
  ///         databaseURL: 'https://your-database.firebase.io')
  ///     );
  ///
  /// See also:
  ///   * [App]
  ///   * [cert]
  ///   * [certFromPath]
  App initializeApp([js.AppOptions options, String name]) {
    if (options == null && name == null) {
      // Special case for default app with Application Default Credentials.
      name = js.defaultAppName;
      if (!_apps.containsKey(name)) {
        _apps[name] = new App(_admin.initializeApp());
      }
      return _apps[name];
    }

    name ??= js.defaultAppName;
    if (!_apps.containsKey(name)) {
      _apps[name] = new App(_admin.initializeApp(options, name));
    }
    return _apps[name];
  }

  /// Creates [App] certificate.
  js.Credential cert({
    @required String projectId,
    @required String clientEmail,
    @required String privateKey,
  }) {
    return _admin.credential.cert(new js.ServiceAccountConfig(
      project_id: projectId,
      client_email: clientEmail,
      private_key: privateKey,
    ));
  }

  /// Creates app certificate from service account file at specified [path].
  js.Credential certFromPath(String path) {
    return _admin.credential.cert(path);
  }
}
