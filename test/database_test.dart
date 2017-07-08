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
    App app;

    setUpAll(() {
      app = initFirebaseApp();
    });

    tearDownAll(() {
      return app.delete();
    });

    test('write and read', () async {
      var db = app.database();
      var ref = db.ref('/test');
      var value = new DateTime.now().toIso8601String();
      await ref.set(value);
      var snapshot = await ref.once('value');
      expect(snapshot.val(), value);
    });
  });
}
