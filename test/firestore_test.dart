// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

@TestOn('node')
import 'dart:async';

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
        expect(data, const TypeMatcher<DocumentData>());
        expect(data, hasLength(3));
        expect(data.keys, hasLength(3));
        expect(data.keys, contains('name'));
        expect(data.keys, contains('profile.url'));
        expect(data.keys, contains('nested'));
        expect(data.getString('name'), 'Firestore');
        expect(data.getString('profile.url'), 'https://pic.com/123');
        var nested = data.getNestedData('nested');
        expect(nested, const TypeMatcher<DocumentData>());
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

      // test setter and getters and fromMap/toMap round trip for
      // all types
      test('get set', () {
        var data = new DocumentData();
        DateTime now = new DateTime.now();
        data.setInt('intVal', 1);
        data.setDouble('doubleVal', 1.5);
        data.setBool('boolVal', true);
        data.setString('stringVal', 'text');
        data.setDateTime('dateVal', now);
        data.setGeoPoint('geoVal', new GeoPoint(23.03, 19.84));
        data.setBlob('blob', new Blob([1, 2, 3]));
        data.setReference('refVal', app.firestore().document('users/23'));
        data.setList('listVal', [23, 84]);
        var nestedData = new DocumentData();
        nestedData.setString('nestedVal', 'very nested');
        data.setNestedData('nestedData', nestedData);
        data.setFieldValue('serverTimestampFieldValue',
            Firestore.fieldValues.serverTimestamp());
        data.setFieldValue('deleteFieldValue', Firestore.fieldValues.delete());

        _check() {
          expect(data.keys.length, 12);
          expect(data.getInt('intVal'), 1);
          expect(data.getDouble('doubleVal'), 1.5);
          expect(data.getBool('boolVal'), true);
          expect(data.getString('stringVal'), 'text');
          expect(data.getDateTime('dateVal'), now);
          expect(data.getGeoPoint('geoVal'), new GeoPoint(23.03, 19.84));
          expect(data.getBlob('blob').data, [1, 2, 3]);
          var documentReference = data.getReference('refVal');
          expect(documentReference.path, 'users/23');
          expect(data.getList('listVal'), [23, 84]);
          DocumentData nestedData = data.getNestedData('nestedData');
          expect(nestedData.keys.length, 1);
          expect(nestedData.getString('nestedVal'), 'very nested');
          // Check the field value (no getter here)
          Map<String, dynamic> map = data.toMap();
          expect(map['serverTimestampFieldValue'],
              Firestore.fieldValues.serverTimestamp());
          expect(map['deleteFieldValue'], Firestore.fieldValues.delete());
        }

        _check();
        // from/to map
        data = new DocumentData.fromMap(data.toMap());
        _check();
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
          'blobVal': new Blob([1, 2, 3]),
          'refVal': app.firestore().document('users/23'),
          'listVal': [23, 84],
          'nestedVal': {'nestedKey': 'much nested'},
          'serverTimestamp': Firestore.fieldValues.serverTimestamp()
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
        expect(result.getBlob('blobVal').data, [1, 2, 3]);
        var docRef = result.getReference('refVal');
        expect(docRef, const TypeMatcher<DocumentReference>());
        expect(docRef.path, 'users/23');
        expect(result.getList('listVal'), [23, 84]);
        var nested = result.getNestedData('nestedVal');
        expect(nested.getString('nestedKey'), 'much nested');
        expect(result.getDateTime('serverTimestamp'), isNotNull);
      });

      test('$DocumentData.toMap', () async {
        var date = new DateTime.now();
        var ref = app.firestore().document('tests/data-types-toMap');
        var data = new DocumentData.fromMap({
          'boolVal': true,
          'stringVal': 'text',
          'intVal': 23,
          'doubleVal': 19.84,
          'dateVal': date,
          'geoVal': new GeoPoint(23.03, 19.84),
          'refVal': app.firestore().document('users/23'),
          'blobVal': new Blob([4, 5, 6]),
          'listVal': [23, 84]
        });
        var nested = new DocumentData.fromMap({'nestedVal': 'very nested'});
        data.setNestedData('nestedData', nested);
        var fakeGeoPoint = new DocumentData.fromMap(
            {'latitude': 23.03, 'longitude': 84.19, 'toString': 'GeoPoint'});
        data.setNestedData('fakeGeoPoint', fakeGeoPoint);
        var fakeRef = new DocumentData.fromMap(
            {'firestore': 'Nope', 'id': 'Nah', 'onSnapshot': 'Function'});
        data.setNestedData('fakeRef', fakeRef);
        var fakeDate = new DocumentData.fromMap(
            {'toDateString': 'date', 'getTime': 'Function'});
        data.setNestedData('fakeDate', fakeDate);
        await ref.setData(data);

        var snapshot = await ref.get();
        var result = snapshot.data.toMap();
        expect(result['boolVal'], isTrue);
        expect(result['stringVal'], 'text');
        expect(result['intVal'], 23);
        expect(result['doubleVal'], 19.84);
        expect(result['dateVal'], date);
        expect(result['geoVal'], new GeoPoint(23.03, 19.84));
        expect((result['blobVal'] as Blob).data, [4, 5, 6]);
        var docRef = result['refVal'];
        expect(docRef, const TypeMatcher<DocumentReference>());
        expect(docRef.path, 'users/23');
        expect(result['listVal'], [23, 84]);
        expect(result['nestedData'], {'nestedVal': 'very nested'});
        expect(result['fakeGeoPoint'],
            {'latitude': 23.03, 'longitude': 84.19, 'toString': 'GeoPoint'});
        expect(result['fakeRef'],
            {'firestore': 'Nope', 'id': 'Nah', 'onSnapshot': 'Function'});
        expect(result['fakeDate'],
            {'toDateString': 'date', 'getTime': 'Function'});
      });

      test('unsupported data types', () async {
        var ref = app.firestore().document('tests/unsupported');
        await ref.setData(new DocumentData()
          ..setGeoPoint('geoVal', new GeoPoint(23.03, 19.84)));
        var snapshot = await ref.get();
        var data = snapshot.data;
        expect(() => data.getList('geoVal'), throwsStateError);
      });

      test('lists with complex types', () async {
        var ref = app.firestore().document('tests/complex-lists');
        var data = new DocumentData();
        data.setList('data', [
          new DateTime.now(),
          new GeoPoint(1.0, 2.0),
          new Blob([1, 2, 3]),
          ref,
        ]);
        await ref.setData(data);

        var snapshot = await ref.get();
        var result = snapshot.data.getList('data');
        expect(result, hasLength(4));
        expect(result.elementAt(0), const TypeMatcher<DateTime>());
        expect(result.elementAt(1), const TypeMatcher<GeoPoint>());
        expect(result.elementAt(2), const TypeMatcher<Blob>());
        expect(result.elementAt(3), const TypeMatcher<DocumentReference>());
      });

      test('delete field', () async {
        var ref = app.firestore().document('tests/delete_field');

        // Make sure FieldValue class is exported by using it here
        FieldValue fieldValueDelete = Firestore.fieldValues.delete();

        // create document
        var documentData = new DocumentData();
        documentData.setString("some_key", "some_value");
        documentData.setString("other_key", "other_value");
        await ref.setData(documentData);

        // read it
        documentData = (await ref.get()).data;
        expect(documentData.getString("some_key"), "some_value");

        // delete field
        var updateData = new UpdateData();
        updateData.setFieldValue("some_key", fieldValueDelete);
        await ref.updateData(updateData);

        // read again
        documentData = (await ref.get()).data;
        expect(documentData.getString("some_key"), isNull);
        expect(documentData.has("some_key"), isFalse);
        expect(documentData.getString("other_key"), "other_value");
      });

      test('set options', () async {
        var ref = app.firestore().document('tests/set_options');

        var documentData = new DocumentData();
        documentData.setInt('value1', 1);
        documentData.setInt('value2', 2);
        await ref.setData(documentData);

        documentData = new DocumentData();
        documentData.setInt('value2', 3);

        // Set with merge, value1 should remain
        await ref.setData(documentData, new SetOptions(merge: true));
        var readData = (await ref.get()).data;
        expect(readData.toMap(), {'value1': 1, 'value2': 3});

        // Set without merge, value1 should be gone
        documentData.setInt('value2', 4);
        await ref.setData(documentData);
        readData = (await ref.get()).data;
        expect(readData.toMap(), {'value2': 4});
      });
    });

    group('$CollectionReference', () {
      var ref = app.firestore().collection('users');

      test('parent of root collection', () {
        final parent = ref.parent;
        expect(parent, const TypeMatcher<DocumentReference>());
        expect(parent.path, isEmpty);
        expect(parent.documentID, isNull);
      });

      test('get new document', () {
        final doc = ref.document();
        expect(doc.documentID, isNotEmpty);
      });

      test('get document from collection', () {
        final doc = ref.document('23');
        expect(doc.documentID, '23');
        expect(doc.path, 'users/23');
      });

      test('add document to collection', () async {
        final point = new GeoPoint(37.7991232, -122.4485953);
        final data = new DocumentData.fromMap({'name': 'Added Doc'});
        data.setGeoPoint("location", point);
        final doc = await ref.add(data);
        expect(doc.documentID, isNotNull);
        final snapshot = await doc.get();
        var result = snapshot.data;
        expect(result.getString('name'), 'Added Doc');
        expect(result.getGeoPoint('location'), point);
      });

      test('set new document in collection', () async {
        final doc = ref.document('abc');
        expect(doc.documentID, 'abc');
        expect(doc.path, 'users/abc');
      });
    });

    group('$DocumentQuery', () {
      setUpAll(() async {
        // setup tests/query/docs content as expected in the tests
        var ref = app.firestore().collection('tests/query/docs');
        var snapshot = await ref.get();

        // Some test assume that this collection is empty or already contains
        // one item. On the first ever call, create the item
        if (snapshot.isEmpty) {
          await ref.add(new DocumentData()..setString('name', 'John Doe'));
        }
      });

      test('get query snapshot', () async {
        var ref = app.firestore().collection('tests/query/docs');
        var snapshot = await ref.get();
        expect(snapshot, isNotEmpty);
        expect(snapshot.documents, hasLength(1));
        expect(snapshot.documentChanges, hasLength(1));
        var doc = snapshot.documents.first;
        expect(doc.data.getString('name'), 'John Doe');
        var change = snapshot.documentChanges.first;
        expect(change.type, isNull);
      });

      test('query filter with document reference', () async {
        var collection = app.firestore().collection('tests/query/where-ref');
        var doc1 = collection.document();
        var doc2 = collection.document();
        await doc2.setData(new DocumentData.fromMap({'name': 'doc2'}));
        var data1 = new DocumentData();
        data1.setReference('ref', doc2);
        data1.setString('name', 'doc1');
        await doc1.setData(data1);

        var query = collection.where('ref', isEqualTo: doc2);
        var snapshot = await query.get();
        expect(snapshot, isNotEmpty);
        expect(snapshot.documents, hasLength(1));
        expect(snapshot.documentChanges, hasLength(1));
        var doc = snapshot.documents.first;
        expect(doc.data.getString('name'), 'doc1');
        expect(doc.data.getReference('ref'),
            const TypeMatcher<DocumentReference>());
      });

      test('get empty query snapshot', () async {
        var ref = app.firestore().collection('tests/query/none');
        var snapshot = await ref.get();
        expect(snapshot, isEmpty);
        expect(snapshot.documents, isNotNull);
        expect(snapshot.documents, isEmpty);
        expect(snapshot.documentChanges, isNotNull);
        expect(snapshot.documentChanges, isEmpty);
      });

      test('listen for query snapshot updates', () async {
        var ref = app.firestore().collection('tests/query/docs');
        Completer<QuerySnapshot> completer = new Completer<QuerySnapshot>();
        var subscription = ref.snapshots.listen((event) {
          completer.complete(event);
        });
        var snapshot = await completer.future;
        subscription.cancel();
        expect(snapshot, isNotNull);
        expect(snapshot, isNotEmpty);
        expect(snapshot.documents, hasLength(1));
      });

      test('select', () async {
        var collRef = app.firestore().collection('tests/query/select');

        // set the content
        var docRef = collRef.document('one');
        await docRef.setData(
            new DocumentData()..setInt('field1', 1)..setInt('field2', 2));

        QuerySnapshot querySnapshot = await collRef.select(['field2']).get();
        var documentData = querySnapshot.documents.first.data;
        expect(documentData.has('field2'), isTrue);
        expect(documentData.has('field1'), isFalse);

        querySnapshot = await collRef.select(['field2']).get();
        documentData = querySnapshot.documents.first.data;
        expect(documentData.has('field2'), isTrue);
        expect(documentData.has('field1'), isFalse);
      });

      test('order and limits', () async {
        var collRef =
            app.firestore().collection('tests/query/order_and_limits');

        // Create or update the content
        var docRefOne = collRef.document('one');
        await docRefOne.setData(new DocumentData()..setInt('value', 1));
        var docRefTwo = collRef.document('two');
        await docRefTwo.setData(new DocumentData()..setInt('value', 2));

        List<DocumentSnapshot> list;

        // limit
        QuerySnapshot querySnapshot = await collRef.limit(1).get();
        list = querySnapshot.documents;
        expect(list.length, 1);

        // offset
        querySnapshot = await collRef.orderBy('value').offset(1).get();
        list = querySnapshot.documents;
        expect(list.length, 1);

        // order by
        querySnapshot = await collRef.orderBy('value').get();
        list = querySnapshot.documents;
        expect(list.length, 2);
        expect(list.first.reference.documentID, "one");

        // desc
        querySnapshot = await collRef.orderBy('value', descending: true).get();
        list = querySnapshot.documents;
        expect(list.length, 2);
        expect(list.first.reference.documentID, "two");

        // start at
        querySnapshot =
            await collRef.orderBy('value').startAt(values: [2]).get();
        list = querySnapshot.documents;
        expect(list.length, 1);
        expect(list.first.reference.documentID, "two");

        // start after
        querySnapshot =
            await collRef.orderBy('value').startAfter(values: [1]).get();
        list = querySnapshot.documents;
        expect(list.length, 1);
        expect(list.first.reference.documentID, "two");

        // end at
        querySnapshot = await collRef.orderBy('value').endAt(values: [1]).get();
        list = querySnapshot.documents;
        expect(list.length, 1);
        expect(list.first.reference.documentID, "one");

        // end before
        querySnapshot =
            await collRef.orderBy('value').endBefore(values: [2]).get();
        list = querySnapshot.documents;
        expect(list.length, 1);
        expect(list.first.reference.documentID, "one");

        // start after using snapshot
        querySnapshot = await collRef
            .orderBy('value')
            .startAfter(snapshot: list.first)
            .get();
        list = querySnapshot.documents;
        expect(list.length, 1);
        expect(list.first.reference.documentID, "two");

        // where
        querySnapshot = await collRef.where('value', isGreaterThan: 1).get();
        list = querySnapshot.documents;
        expect(list.length, 1);
        expect(list.first.reference.documentID, "two");
      });

      test('snapshots changes', () async {
        var collRef =
            app.firestore().collection('tests/query/snapshots_changes');
        var docRef = collRef.document('item');

        // delete item
        await docRef.delete();

        // We'll them listen for changes while creating/modifying/deleting
        // the same item
        final int stepCount = 4;

        // Create a completer for each step
        var completers = new List<Completer<List<DocumentChange>>>.generate(
            stepCount, (_) => new Completer<List<DocumentChange>>());

        int stepIndex = 0;
        var subscription =
            collRef.snapshots.listen((QuerySnapshot querySnapshot) {
          // complete each step when receiving data
          if (stepIndex < stepCount) {
            completers[stepIndex++].complete(querySnapshot.documentChanges);
          }
        });

        int index = 0;
        List<DocumentChange> documentChanges;

        // wait for receiving first data, ignore result
        await completers[index++].future;

        // create it
        await docRef.setData(new DocumentData());
        // wait for receiving change data
        documentChanges = await completers[index++].future;
        // expect creation
        expect(documentChanges.length, 1);
        expect(documentChanges.first.type, DocumentChangeType.added);

        // modify it
        await docRef.setData(new DocumentData()..setInt('value', 1));
        // wait for receiving change data
        documentChanges = await completers[index++].future;
        // expect a modified item
        expect(documentChanges.length, 1);
        expect(documentChanges.first.type, DocumentChangeType.modified);

        // delete it
        await docRef.delete();
        // wait for receiving change data
        documentChanges = await completers[index++].future;
        // expect deletion
        expect(documentChanges.length, 1);
        expect(documentChanges.first.type, DocumentChangeType.removed);

        await subscription.cancel();
      });
    });

    group('$Transaction', () {
      test('runTransaction', () async {
        var collRef = app.firestore().collection('tests/transaction/simple');
        // this one will be created
        var doc1Ref = collRef.document('item1');
        // this one will be updated
        var doc2Ref = collRef.document('item2');
        // this one will be set
        var doc3Ref = collRef.document('item3');
        // this one will be deleted
        var doc4Ref = collRef.document('item4');

        var doc4Value = 4;
        await doc1Ref.delete();
        await doc2Ref.setData(new DocumentData()..setInt('value', 2));
        await doc3Ref.setData(new DocumentData()..setInt('value', 3));
        await doc4Ref.setData(new DocumentData()..setInt('value', doc4Value));

        List<DocumentSnapshot> list =
            await app.firestore().runTransaction((Transaction tx) async {
          var query = await tx.getQuery(
              collRef.orderBy('value').where('value', isGreaterThan: 1));
          var list = query.documents;

          var doc4 = (await tx.get(doc4Ref)).data.getInt('value');
          tx.create(doc1Ref, new DocumentData()..setInt('value', 1 + doc4));
          tx.update(
              doc2Ref, new UpdateData()..setInt('other.value', 22 + doc4));
          tx.set(doc3Ref, new DocumentData()..setInt('value', 3 + doc4));
          tx.set(doc3Ref, new DocumentData()..setInt('other.value', 33 + doc4),
              merge: true);
          tx.delete(doc4Ref);

          return list;
        });

        expect(list.length, 3);
        expect(list[0].documentID, "item2");
        expect(list[1].documentID, "item3");
        expect(list[2].documentID, "item4");

        expect((await doc1Ref.get()).data.toMap(), {'value': 1 + doc4Value});
        expect((await doc2Ref.get()).data.toMap(), {
          'value': 2,
          'other': {
            'value': 22 + doc4Value,
          },
        });
        expect((await doc3Ref.get()).data.toMap(), {
          'value': 3 + doc4Value,
          'other.value': 33 + doc4Value,
        });
        expect((await doc4Ref.get()).exists, isFalse);
      });

      test('runTransaction, test Precondition lastUpdateTime', () async {
        var collRef =
            app.firestore().collection('tests/transaction/precondition');
        // this one will be updated
        var doc1Ref = collRef.document('item1');
        // this one will be deleted
        var doc2Ref = collRef.document('item2');

        await doc1Ref.setData(new DocumentData()..setInt('value', 1));
        await doc2Ref.setData(new DocumentData()..setInt('value', 2));
        var doc1UpdateTime1 = (await doc1Ref.get()).updateTime;
        var doc2UpdateTime1 = (await doc2Ref.get()).updateTime;

        await doc1Ref.setData(new DocumentData()..setInt('value', 10));
        await doc2Ref.setData(new DocumentData()..setInt('value', 20));
        var doc1UpdateTime2 = (await doc1Ref.get()).updateTime;
        var doc2UpdateTime2 = (await doc2Ref.get()).updateTime;

        Future result = app.firestore().runTransaction((Transaction tx) async {
          var doc2 = (await tx.get(doc2Ref)).data;
          tx.update(
              doc1Ref, new UpdateData()..setInt('value', doc2.getInt('value')),
              lastUpdateTime: doc1UpdateTime1);
          tx.delete(doc2Ref, lastUpdateTime: doc2UpdateTime1);
        });

        var error = await result.catchError((error) => error);
        expect(error.toString(), contains('FAILED_PRECONDITION'));

        expect((await doc1Ref.get()).data.toMap(), {'value': 10});
        expect((await doc2Ref.get()).data.toMap(), {'value': 20});

        await app.firestore().runTransaction((Transaction tx) async {
          var doc2 = (await tx.get(doc2Ref)).data.getInt('value');
          tx.update(doc1Ref, new UpdateData()..setInt('value', doc2),
              lastUpdateTime: doc1UpdateTime2);
          tx.delete(doc2Ref, lastUpdateTime: doc2UpdateTime2);
        });
        expect((await doc1Ref.get()).data.toMap(), {'value': 20});
        expect((await doc2Ref.get()).exists, isFalse);
      });

      test('runTransaction, increment counter 5 times in async', () async {
        /// This test originally had 10 updates which was causing following
        /// error:
        ///
        /// ABORTED: Too much contention on these documents. Please try again.
        var collRef = app.firestore().collection('tests/transaction/async');
        var doc1Ref = collRef.document('counter');
        await doc1Ref.setData(new DocumentData()..setInt('value', 1));

        List<Future<int>> futures = new List();
        List<dynamic> errors = new List();
        List<int> complete = new List();

        var futuresCount = 5;
        for (int i = 0; i < futuresCount; i++) {
          var transaction =
              app.firestore().runTransaction<int>((Transaction tx) async {
            var doc1 = await tx.get(doc1Ref);
            var val = doc1.data.getInt('value') + 1;
            tx.set(doc1Ref, new DocumentData()..setInt('value', val));
            return val;
          });
          futures.add(transaction.then((int val) {
            complete.add(val);
          }, onError: (e) {
            errors.add(e);
          }));
        }

        await Future.wait(futures);
        expect(errors.length + complete.length, futuresCount);

        var value = (await doc1Ref.get()).data.getInt('value');
        expect(errors, isEmpty, reason: errors.toString());
        expect(complete, hasLength(futuresCount),
            reason: '${complete} of length ${complete.length}');
        expect(value, 6);
      });
    });

    group('$WriteBatch', () {
      test('batch', () async {
        var collRef = app.firestore().collection('tests/batch/simple');
        // this one will be created
        var doc1Ref = collRef.document('item1');
        // this one will be updated
        var doc2Ref = collRef.document('item2');
        // this one will be set
        var doc3Ref = collRef.document('item3');
        // this one will be deleted
        var doc4Ref = collRef.document('item4');

        await doc1Ref.delete();
        await doc2Ref.setData(new DocumentData()..setInt('value', 2));
        await doc4Ref.setData(new DocumentData()..setInt('value', 4));

        var batch = app.firestore().batch();
        batch.setData(doc1Ref, new DocumentData()..setInt('value', 1));
        batch.updateData(doc2Ref, new UpdateData()..setInt('other.value', 22));
        batch.setData(doc3Ref, new DocumentData()..setInt('value', 3));
        batch.delete(doc4Ref);
        await batch.commit();

        expect((await doc1Ref.get()).data.toMap(), {'value': 1});
        expect((await doc2Ref.get()).data.toMap(), {
          'value': 2,
          'other': {'value': 22}
        });
        expect((await doc3Ref.get()).data.toMap(), {'value': 3});
        expect((await doc4Ref.get()).exists, isFalse);
      });
    });
  });
}
