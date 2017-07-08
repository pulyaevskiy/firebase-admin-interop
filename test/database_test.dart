// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

@TestOn('node')
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:node_interop/node_interop.dart';
import 'package:test/test.dart';
import 'setup.dart';

final platform = new NodePlatform();
final Map<String, String> env = platform.environment;

void main() {
  group('Database', () {
    FirebaseAdmin admin;
    App app;

    setUpAll(() {
      installNodeModules();
      admin = new FirebaseAdmin();
      app = admin.initializeApp(new AppOptions(
        credential: admin.credential.cert(appCredentials),
        databaseUrl: env['FIREBASE_DATABASE_URL'],
      ));
    });

    tearDownAll(() {
      return app.delete();
    });

    test('write and read', () async {
      var db = admin.database();
      var ref = db.ref('/test');
      var value = new DateTime.now().toIso8601String();
      await ref.set(value);
      var snapshot = await ref.once('value');
      expect(snapshot.val(), value);
    });
  });
}

Map<String, String> get appCredentials {
  return {
    'project_id': env['FIREBASE_PROJECT_ID'],
    'client_email': env['FIREBASE_CLIENT_EMAIL'],
    'private_key': env['FIREBASE_PRIVATE_KEY'].replaceAll(r'\n', '\n'),
  };
}
