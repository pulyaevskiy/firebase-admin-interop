// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:built_value/serializer.dart';
import 'package:meta/meta.dart';

import 'app.dart';
import 'bindings.dart' as js;
import 'database.dart';
import 'serializers.dart' as s;

/// Provides access to Firebase Admin APIs.
///
/// To start using Firebase services initialize a Firebase application
/// with [initializeApp] method.
class FirebaseAdmin {
  final Map<String, App> _apps = new Map();

  static FirebaseAdmin get instance => _instance ??= new FirebaseAdmin._();
  static FirebaseAdmin _instance;

  FirebaseAdmin._();

  /// Registers [serializers] to be used by this library.
  ///
  /// Makes Firebase services like Realtime Database and Firestore aware
  /// of your application's models and available serializers.
  ///
  /// You are required to register serializers if you intend to use them in
  /// calls to [Reference.setValue], [DataSnapshot.val] and others.
  void registerSerializers(Serializers serializers) =>
      s.registerSerializers(serializers);

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
  App initializeApp(js.AppOptions options, [String name]) {
    assert(options != null);
    name ??= js.defaultAppName;
    js.initFirebaseAdmin();
    if (!_apps.containsKey(name)) {
      _apps[name] = new App(js.initializeApp(options, name));
    }
    return _apps[name];
  }

  /// Creates [App] certificate.
  js.Credential cert({
    @required String projectId,
    @required String clientEmail,
    @required String privateKey,
  }) {
    js.initFirebaseAdmin();
    return js.cert(new js.ServiceAccountConfig(
      project_id: projectId,
      client_email: clientEmail,
      private_key: privateKey,
    ));
  }

  /// Creates app certificate from service account file at specified [path].
  js.Credential certFromPath(String path) {
    js.initFirebaseAdmin();
    return js.cert(path);
  }
}
