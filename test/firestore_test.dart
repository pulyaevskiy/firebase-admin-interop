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
        final data = new DocumentData.fromMap({
          'name': 'Firestore',
          'profile.url': "https://pic.com/123",
        });
        final nested = new DocumentData.fromMap({'author': 'Unknown'});
        data.setNestedData('nested', nested);
        // This completely overwrites the whole document.
        await ref.setData(data);
      });

      test('read-only fields', () {
        expect(ref.path, 'users/23');
        expect(ref.documentID, '23');
      });

      test('get value once', () async {
        var snapshot = await ref.get();
        var data = snapshot.data;
        expect(data, new isInstanceOf<DocumentData>());
        expect(data, hasLength(3));
        expect(data.getString('name'), 'Firestore');
        expect(data.getString('profile.url'), 'https://pic.com/123');
        var nested = data.getNestedData('nested');
        expect(nested, new isInstanceOf<DocumentData>());
        expect(nested, hasLength(1));
        expect(nested.getString('author'), 'Unknown');
      });

      test('update value', () async {
        await ref.updateData(new UpdateData.fromMap({
          'nested.author': 'Isaac Asimov',
        }));
        var snapshot = await ref.get();
        var data = snapshot.data;
        var nested = data.getNestedData('nested');
        expect(nested.getString('author'), 'Isaac Asimov');
      });

      test('data types', () async {
        var date = new DateTime.now();
        var ref = app.firestore().document('tests/data-types');
        var data = new DocumentData.fromMap({
          'boolVal': true,
          'stringVal': 'text',
          'intVal': 23,
          'doubleVal': 19.84,
          'dateVal': date,
          'geoVal': new GeoPoint(23.03, 19.84),
          'refVal': app.firestore().document('users/23'),
          'listVal': [23, 84]
        });
        await ref.setData(data);

        var snapshot = await ref.get();
        var result = snapshot.data;
        expect(result.getBool('boolVal'), isTrue);
        expect(result.getString('stringVal'), 'text');
        expect(result.getInt('intVal'), 23);
        expect(result.getDouble('doubleVal'), 19.84);
        expect(result.getDateTime('dateVal'), date);
        expect(result.getGeoPoint('geoVal'), new GeoPoint(23.03, 19.84));
        var docRef = result.getReference('refVal');
        expect(docRef, new isInstanceOf<DocumentReference>());
        expect(docRef.path, 'users/23');
        expect(result.getList('listVal'), [23, 84]);
      });

      test('unsupported data types', () async {
        var ref = app.firestore().document('tests/unsupported');
        var snapshot = await ref.get();
        var data = snapshot.data;
        expect(() => data.getList('geoVal'),
            throwsA(new isInstanceOf<AssertionError>()));

        var setData = new DocumentData();
        expect(() {
          setData.setList('foo', [new GeoPoint(1.0, 2.2)]);
        }, throwsA(new isInstanceOf<AssertionError>()));
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
        var data = snapshot.data;
        expect(data.getString('name'), 'Added Doc');
      });

      test('set new document in collection', () async {
        final doc = ref.document('abc');
        expect(doc.documentID, 'abc');
        expect(doc.path, 'users/abc');
      });
    });
  });
}
