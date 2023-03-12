// Copyright (c) 2018, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

@TestOn('node')
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:node_interop/node.dart' as node;
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('Auth', () {
    App? app;

    setUpAll(() async {
      app = initFirebaseApp();
      UserRecord? user;
      try {
        user = await app!.auth().getUser('testuser');
      } catch (_) {}
      if (user == null) {
        await app!.auth().createUser(CreateUserRequest(uid: 'testuser'));
      }
    });

    tearDownAll(() {
      return app!.delete();
    });

    test('createCustomToken', () async {
      var token =
          await app!.auth().createCustomToken('testuser', {'role': 'admin'});
      expect(token, isNotEmpty);
    });

    test('getUser', () async {
      var user = await app!.auth().getUser('testuser');
      expect(user.uid, 'testuser');
    });

    test('getUser which does not exist', () async {
      var result = app!.auth().getUser('noSuchUser');
      expect(result, throwsA(const TypeMatcher<node.JsError>()));
    });

    test('listUsers', () async {
      var result = await app!.auth().listUsers();
      expect(result.users, isNotEmpty);
    });
  });
}
