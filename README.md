# Firebase Admin Interop Library for Dart

[![Build Status](https://travis-ci.org/pulyaevskiy/firebase-admin-interop.svg?branch=master)](https://travis-ci.org/pulyaevskiy/firebase-admin-interop)

Write server-side Firebase applications in Dart using NodeJS as a runtime.
This is an early preview, alpha open-source project.

* [What is this?](#what-is-this?)
* [Examples](#examples)
* [Status](#status)
* [Usage](#usage)
* [Features](#features)
  * [built_value support](#built_value-support)

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

This is a early preview, alpha version which is far from being feature
complete. Breaking changes are likely to occur.

Make sure to checkout [CHANGELOG.md](https://github.com/pulyaevskiy/firebase-admin-interop/blob/master/CHANGELOG.md)
after every release, all notable changes and upgrade instructions will
be described there.

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

## Features

### built_value support

As of `0.1.0-beta.2` this library introduced preliminary support for
models and serializers generated with
[built_value](https://pub.dartlang.org/packages/built_value) package.

Here is general example of how to use it.

#### 1. Create a model

```dart
// file:models.dart
library models;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'models.g.dart';

abstract class Memo implements Built<Memo, MemoBuilder> {
  static Serializer<Memo> get serializer => _$memoSerializer;
  int get id;
  String get title;
  DateTime get createdAt;

  factory Memo([updates(MemoBuilder b)]) = _$Memo;
  Memo._();
}
// Add more models as needed...
```

#### 2. Initialize serializers

```dart
// file:serializers.dart
library serializers;

import 'package:built_value/serializer.dart';
import 'models.dart';

part 'serializers.g.dart';

@SerializersFor(const [
  Memo,
])
final Serializers serializers = _$serializers;
```

#### 3. Register and use serializer with Realtime Database

```dart
import 'dart:async';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';

// Import your models and serializers:
import 'models.dart';
import 'serializers.dart';

Future main() async {
  // Initialize Firebase App as you would do normally:
  var app = FirebaseAdmin.instance.initializeApp(/* your arguments */);

  /// Make Firebase library aware of your serializers:
  FirebaseAdmin.instance.registerSerializers(serializers);

  var ref = app.database().ref('/built-value/memo');

  // Sample model
  var memo = new Memo((builder) {
    builder.id = 23;
    builder.title = 'Built Memo';
    builder.createdAt = new DateTime.now().toUtc();
  });

  // Pass `Memo.serializer` as second argument to `setValue()`
  await ref.setValue(memo, Memo.serializer);

  // Read memo back: pass `Memo.serializer` as 2nd argument to `once()`
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
