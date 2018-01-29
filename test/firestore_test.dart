// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

@TestOn('node')
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  App app = initFirebaseApp();

  group('$Firestore', () {
    tearDownAll(() {
      return app.delete();
    });

    group('$DocumentReference', () {
      var ref = app.firestore().document('users/23');

      setUp(() async {
        // This completely overwrites the whole document.
        await ref.setData({'name': 'Firestore'});
      });

      test('read-only fields', () {
        expect(ref.path, 'users/23');
        expect(ref.documentID, '23');
      });

      test('get value once', () async {
        var snapshot = await ref.get();
        expect(snapshot.data, {'name': 'Firestore'});
      });

      test('update value', () async {
        await ref.updateData({'url': 'https://firestore.something'});
        var snapshot = await ref.get();
        expect(snapshot.data,
            {'name': 'Firestore', 'url': 'https://firestore.something'});
      });
    });

    group('$CollectionReference', () {
      var ref = app.firestore().collection('users');

      test('parent of root collection', () {
        final parent = ref.parent;
        expect(parent, new isInstanceOf<DocumentReference>());
        expect(parent.path, isEmpty);
        expect(parent.documentID, isNull);
      });

      test('get document from collection', () {
        final doc = ref.document('23');
        expect(doc.documentID, '23');
        expect(doc.path, 'users/23');
      });

      test('add document to collection', () async {
        final doc = await ref.add({'name': 'Added Doc'});
        expect(doc.documentID, isNotNull);
        final snapshot = await doc.get();
        expect(snapshot.data, {'name': 'Added Doc'});
      });

      test('set new document in collection', () async {
        final doc = ref.document('abc');
        expect(doc.documentID, 'abc');
        expect(doc.path, 'users/abc');
      });
    });
  });
}
