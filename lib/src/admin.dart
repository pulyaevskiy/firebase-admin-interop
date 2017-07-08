// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:node_interop/node_interop.dart';

import 'bindings/admin.dart';
import 'bindings/core.dart';
import 'database.dart';

final FirebaseAdmin _admin = new FirebaseAdmin._(requireFirebaseAdmin());

class FirebaseAdmin {
  final JsFirebaseAdmin _inner;
  FirebaseAdmin._(this._inner);

  factory FirebaseAdmin() => _admin;

  App initializeApp(AppOptions options) {
    var jsOptions = new JsAppOptions(
      credential: options.credential,
      databaseURL: options.databaseUrl,
    );
    return new App._(_inner.initializeApp(jsOptions));
  }

  Credential get credential =>
      _credential ??= new Credential._(_inner.credential);
  Credential _credential;

  Database database() => _database ??= new Database(_inner.database());
  Database _database;
}

class App {
  final JsApp _inner;

  App._(this._inner);

  String get name => _inner.name;

  Database database() => new Database(_inner.database());

  Future<Null> delete() => jsPromiseToFuture(_inner.delete());
}

class AppOptions {
  final JsCredential credential;
  final String databaseUrl;

  AppOptions({this.credential, this.databaseUrl});
}

class Credential {
  final JsCredential _inner;

  Credential._(this._inner);

  JsCredential cert(dynamic serviceKeyPathOrObject) {
    if (serviceKeyPathOrObject is String) {
      return _inner.cert(serviceKeyPathOrObject);
    } else {
      var config = new JsServiceAccountConfig(
        project_id: serviceKeyPathOrObject['project_id'],
        client_email: serviceKeyPathOrObject['client_email'],
        private_key: serviceKeyPathOrObject['private_key'],
      );
      return _inner.cert(config);
    }
  }
}
