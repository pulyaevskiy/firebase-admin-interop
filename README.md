# Firebase Admin Interop Library for Dart

[![Build Status](https://travis-ci.org/pulyaevskiy/firebase-admin-interop.svg?branch=master)](https://travis-ci.org/pulyaevskiy/firebase-admin-interop)

Write server-side Firebase applications in Dart using NodeJS as a runtime.
This is an early preview, alpha open-source project.

* [What is this?](#what-is-this?)
* [Examples](#examples)
* [Status](#status)
* [Usage](#usage)
  * [built_value integration](#built_value-integration)

## What is this?

This library consists of two main parts. First part contains Dart facade
to Firebase Admin SDK for NodeJS. This is just pure interface
definitions for JavaScript API. The second part defines a higher-level
API layer which abstracts away all the details of interacting with
JavaScript/NodeJS and makes writing Firebase apps as they were your
usual Dart applications.

## Examples

Checkout `example/` folder of this repository for some example apps using
different APIs.

## Status

This is a early preview, alpha version which is not feature
complete. Breaking changes are likely to occur.

Make sure to checkout [CHANGELOG.md](https://github.com/pulyaevskiy/firebase-admin-interop/blob/master/CHANGELOG.md)
after every release, all notable changes and upgrade instructions will
be described there.

Current implementation coverage report:

- [x] admin
- [ ] admin.auth
- [x] admin.app
- [x] admin.credential
- [x] admin.database (~90%)
- [ ] admin.firestore
- [ ] admin.messaging
- [ ] admin.storage



If you found a bug, please don't hesitate to create an issue in the
[issue tracker](http://github.com/pulyaevskiy/firebase-admin-interop/issues/new).

## Usage

Here is a simple example of using Realtime Database client:

```dart
import 'dart:async';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';

Future main() async {
  var serviceAccountKeyFilename = '/absolute/path/to/service-account.json';
  var admin = FirebaseAdmin.instance;
  var cert = admin.certFromPath(serviceAccountKeyFilename);
  var app = admin.initializeApp(credential: cert, databaseUrl: "YOUR_DB_URL");
  var ref = app.database().ref('/test-path');
  // Write value to the database at "/test-path" location.
  await ref.setValue("Hello world");
  // Read value from the same database location.
  var snapshot = await ref.once("value");
  print(snapshot.val()); // prints "Hello world".
}
```

Note that it is only possible to use JSON-compatible values when reading
and writing data to the database. This includes all primitive
types (`int`, `double`, `bool`), string values (`String`) as well as
any `List` or `Map` instance.

As of `0.1.0` this library introduced preliminary support for
models and serializers generated with
[built_value](https://pub.dartlang.org/packages/built_value) package.
This enables you to use any `Built` value with this library.

### built_value integration

Use `FirebaseAdmin.instance.registerSerializers()` to make this library
aware of your models. Then you can pass specific `Serializer` to any
method which reads or writes data to the Realtime Database.

```dart
import 'dart:async';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';

// Import your models and serializers:
import 'models.dart';
import 'serializers.dart';

Future main() async {
  // Initialize Firebase App as you would do normally:
  var app = FirebaseAdmin.instance.initializeApp(/* arguments */);

  /// Make Firebase library aware of your serializers:
  FirebaseAdmin.instance.registerSerializers(serializers);

  // Sample model
  var memo = new Memo((builder) {
    builder.id = 23;
    builder.title = 'Built Memo';
    builder.createdAt = new DateTime.now().toUtc();
  });

  var ref = app.database().ref('/built-value/memo');
  // Note `Memo.serializer` as 2nd argument when writing data to ref.
  await ref.setValue(memo, Memo.serializer);

  // Note `Memo.serializer` as 2nd argument when reading data from ref.
  DataSnapshot<Memo> snapshot = await ref.once<Memo>('value', Memo.serializer);
  Memo storedMemo = snapshot.val();
  print('Value: ${storedMemo}');
  // Prints something close to:
  // Value: Memo {
  //   id=23,
  //   title=Built Memo,
  //   createdAt=2017-10-17 22:46:52.819Z,
  // }
}
```

For more details checkout `example/built_values.dart` and
[documentation](https://www.dartdocs.org/documentation/firebase_admin_interop/latest).

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/pulyaevskiy/firebase-admin-interop/issues
