// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:node_interop/node_interop.dart';
import 'package:test/test.dart';

final platform = new NodePlatform();
final Map<String, String> env = platform.environment;

void main() {
  group('FirebaseAdmin', () {
    test('initializeApp', () {
      var admin = new FirebaseAdmin();
      var app = admin.initializeApp(new AppOptions(
        credential: admin.credential.cert(appCredentials),
        databaseUrl: env['FIREBASE_DATABASE_URL'],
      ));
      expect(app.name, '[DEFAULT]');
    });
  });
}

Map<String, String> get appCredentials {
  return {
    'project_id': env['FIREBASE_PROJECT_ID'],
    'client_email': env['FIREBASE_CLIENT_EMAIL'],
    'private_key': env['FIREBASE_PRIVATE_KEY'],
  };
}
