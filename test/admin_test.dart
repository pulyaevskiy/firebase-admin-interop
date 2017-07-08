// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

@TestOn('node')
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('FirebaseAdmin', () {
    App app;

    setUpAll(() {
      app = initFirebaseApp();
    });

    tearDownAll(() {
      return app.delete();
    });

    test('app name', () {
      expect(app.name, '[DEFAULT]');
    });
  });
}
