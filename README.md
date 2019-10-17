[![Build Status](https://travis-ci.org/pulyaevskiy/firebase-admin-interop.svg?branch=master)](https://travis-ci.org/pulyaevskiy/firebase-admin-interop)

Write server-side Firebase applications in Dart using Node.js as a runtime.

> ### Firestore Timestamps migration:
> Firestore deprecated usage of DateTime objects in favor of custom Timestamp type and recommends
> migrating as soon as possible.
> By default all timestamps are still returned as DateTime objects and you can access them with
> `DocumentData.getDateTime` or `DocumentData.setDateTime`.
> To start using Timestamps you must configure Firestore as follows:
>
> ```dart
> final app = FirebaseAdmin.instance.initializeApp();
> final firestore = app.firestore();
> // Call Firestore.settings at the very beginning before any other calls:
> firestore.settings(FirestoreSettings(timestampsInSnapshots: true));
> // You can read and write data now, but make sure to use new `setTimestamp` and `getTimestamp`
> // methods of `DocumentData`.
> ```

## Installation

1. Add this package as a dependency to your `pubspec.yaml`:

```yaml
dependencies:
  firebase_admin_interop: [latest_version]
```

Run `pub get`.

2. Create `package.json` file to install Node.js modules used by this library:

```json
{
  "dependencies": {
    "firebase-admin": "8.5.0",
    "@google-cloud/firestore": "2.0.0"
  }
}
```

Run `npm install`.

## Usage

Below is a simple example of using Realtime Database client:

```dart
import 'dart:async';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';

Future<void> main() async {
  final serviceAccountKeyFilename = '/absolute/path/to/service-account.json';
  final admin = FirebaseAdmin.instance;
  final cert = admin.certFromPath(serviceAccountKeyFilename);
  final app = admin.initializeApp(new AppOptions(
    credential: cert,
    databaseURL: "YOUR_DB_URL",
  ));
  final ref = app.database().ref('/test-path');
  // Write value to the database at "/test-path" location.
  await ref.setValue("Hello world");
  // Read value from the same database location.
  var snapshot = await ref.once("value");
  print(snapshot.val()); // prints "Hello world".
}

```

Note that it is only possible to use JSON-compatible values when reading
and writing data to the Realtime Database. This includes all primitive
types (`int`, `double`, `bool`), string values (`String`) as well as
any `List` or `Map` instance.

> For Firestore there are a few more supported data types, like `DateTime`
> and `GeoPoint`.

## Building

This library depends on [node_interop][] package which provides Node.js
bindings and [build_node_compilers][] package which allows compiling
Dart applications as Node.js modules.

[node_interop]: https://pub.dartlang.org/packages/node_interop
[build_node_compilers]: https://pub.dartlang.org/packages/build_node_compilers

To enable builders provided by [build_node_compilers][] first add following
dev dependencies to your `pubspec.yaml`:

```yaml
dev_dependencies:
  build_runner: ^1.0.0
  build_node_compilers: ^0.2.0
```

Next, create `build.yaml` file with following contents:

```yaml
targets:
  $default:
    sources:
      - "lib/**"
      - "node/**" # Assuming your main Dart files is in node/ folder (recommended).
      - "test/**"
    builders:
      build_node_compilers|entrypoint:
        options:
          compiler: dart2js # To compile with dart2js by default
```

You can now build your project using `build_runner`:

```bash
# By default compiles with DDC
pub run build_runner build --output=build

# To compile with dart2js:
pub run build_runner build \
  --define="build_node_compilers|entrypoint=compiler=dart2js" \
  --define="build_node_compilers|entrypoint=dart2js_args=[\"--minify\"]" \ # optional, minifies resulting code
  --output=build/
```

## Status

This library is considered stable though not feature complete. It is recommended to check
dev versions for latest updates and bug fixes.

Make sure to checkout [CHANGELOG.md](https://github.com/pulyaevskiy/firebase-admin-interop/blob/master/CHANGELOG.md)
after every release, all notable changes and upgrade instructions will
be described there.

Current implementation coverage report:

- [x] admin
- [x] admin.auth
- [x] admin.app
- [x] admin.credential
- [x] admin.database
- [x] admin.firestore
- [x] admin.messaging
- [ ] admin.storage

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/pulyaevskiy/firebase-admin-interop/issues
