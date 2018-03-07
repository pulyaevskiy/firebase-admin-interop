// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

@TestOn('node')
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  App app = initFirebaseApp();

  group('Database', () {
    tearDownAll(() {
      return app.delete();
    });

    group('Query', () {
      var ref = app.database().ref('/app/users/23');

      setUp(() async {
        await ref.setValue('Firebase');
      });

      test('read value once', () async {
        var snapshot = await ref.once<String>('value');
        expect(snapshot.val(), 'Firebase');
      });

      test('querying works', () async {
        var ref = app.database().ref('/app/users').endAt('Firebase');
        var value = await ref.once('value');
        var records = new Map<String, dynamic>.from(value.val());
        expect(records, hasLength(2));
      });
    });

    group('Reference', () {
      var ref = app.database().ref('/app/users/23');
      var refUpdate = app.database().ref('/tests/refUpdate');

      setUp(() async {
        await refUpdate.remove();
      });

      test('get key', () {
        expect(ref.key, '23');
      });

      test('get parent', () {
        expect(ref.parent, new isInstanceOf<Reference>());
        expect(ref.parent.key, 'users');
        expect(ref.parent, same(ref.parent));
      });

      test('get root', () {
        expect(ref.root, new isInstanceOf<Reference>());
        expect(ref.root.key, isNull);
        expect(ref.root, same(ref.root));
      });

      test('get child()', () {
        var child = ref.child('settings');
        expect(child, new isInstanceOf<Reference>());
        expect(child.key, 'settings');
      });

      test('push()', () {
        var child = ref.child('notifications');
        var item = child.push();
        expect(item, new isInstanceOf<FutureReference>());
        expect(item.key, isNotEmpty);
        expect(item.key, isNot(child.key));
        expect(item.done, completes);
      });

      test('push() with value', () {
        var child = ref.child('notifications');
        var item = child.push('You got a message.');
        expect(item, new isInstanceOf<FutureReference>());
        expect(item.key, isNotEmpty);
        expect(item.key, isNot(child.key));
        expect(item.done, completes);
      });

      test('remove()', () {
        expect(ref.remove(), completes);
      });

      test('setValue()', () {
        expect(ref.setValue('Firebase'), completes);
      });

      test('update()', () async {
        await refUpdate.update({'num': 23, 'nested/thing': '1984'});
        var snapshot = await refUpdate.once('value');
        Map<String, dynamic> data = snapshot.val();
        expect(data, hasLength(2));
        expect(data['num'], 23);
        expect(data['nested']['thing'], '1984');
      });
    });

    group('DataSnapshot', () {
      var ref = app.database().ref('/app/users/3/notifications');
      var childKey;

      setUp(() async {
        await ref.remove();
        var childRef = ref.push('You got a message');
        childKey = childRef.key;
        await childRef.done;
        await ref.push('Stuff to do').done;
      });

      test('get key', () async {
        var snapshot = await ref.once('value');
        expect(snapshot.key, 'notifications');
      });

      test('exists()', () async {
        var snapshot = await ref.once('value');
        expect(snapshot.exists(), isTrue);
      });

      test('child()', () async {
        var snapshot = await ref.once('value');
        var childSnapshot = snapshot.child<String>(childKey);
        expect(childSnapshot.key, childKey);
        expect(childSnapshot.exists(), isTrue);
      });

      test('child() not exists', () async {
        var snapshot = await ref.once('value');
        var childSnapshot = snapshot.child<String>('no-such-child');
        expect(childSnapshot.key, 'no-such-child');
        expect(childSnapshot.exists(), isFalse);
      });

      test('hasChild()', () async {
        var snapshot = await ref.once('value');
        expect(snapshot.hasChild('no-such-child'), isFalse);
        expect(snapshot.hasChild(childKey), isTrue);
      });

      test('hasChildren()', () async {
        var snapshot = await ref.once('value');
        expect(snapshot.hasChildren(), isTrue);
      });

      test('numChildren()', () async {
        var snapshot = await ref.once('value');
        expect(snapshot.numChildren(), 2);
      });

      test('forEach', () async {
        var snapshot = await ref.once('value');
        var values = [];
        snapshot.forEach<String>((child) {
          values.add(child.val());
        });
        expect(values, ['You got a message', 'Stuff to do']);
      });

      test('val()', () async {
        var snapshot = await ref.once<Map>('value');
        var val = snapshot.val();
        expect(val, isMap);
        expect(val.length, 2);
      });
    });
  });
}
