// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

@TestOn('node')
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:test/test.dart';

import 'setup.dart';

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
      await ref.setValue(value);
      var snapshot = await ref.once('value');
      expect(snapshot.val(), value);
    });

    test('DataSnapshot.forEach', () async {
      var db = app.database();
      await db.ref('/forEachTest/ch1').setValue(1);
      await db.ref('/forEachTest/ch2').setValue(2);
      var snapshot = await db.ref('/forEachTest').once('value');
      var values = [];
      snapshot.forEach((child) {
        int val = child.val();
        values.add(val);
      });
      expect(values, [1, 2]);
    });
  });
}
