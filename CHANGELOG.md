## 2.1.0

Upgraded to support firebase-admin Messaging features to send cloud message payloads to device, topic, all, multicast, and subscribe/unsubscribe from topic.
```dart
  NotificationMessagePayload notification = NotificationMessagePayload(
    title: title,
    body: body,
    clickAction: "FLUTTER_NOTIFICATION_CLICK",
  );
  MessagingPayload payload = new MessagingPayload(notification: notification, data: DataMessagePayload(data: {"doc" : event.reference.path}));
  MessagingDevicesResponse result = await firestoreApp.messaging().sendToDevice(token, payload);
  // or firestoreApp.messaging().sendToTopic(topic, payload);
```
- Breaking change: Updated versions of many dependencies in pubspec

## 2.0.0

Upgraded to support firebase-admin Node.js SDK 8.0.0 or greater and `@google-cloud/firestore` 2.0.0.

Make sure to update your `package.json` with following version constraints:

```json
{
  "dependencies": {
    "firebase-admin": "8.5.0",
    "@google-cloud/firestore": "2.0.0"
  }
}
```

- Breaking change: library now requires Node.js >= 8.13.0
- Breaking change: DocumentReference `getCollections` method renamed to `listCollections`.
- Breaking change: Firestore `getCollections` method renamed to `listCollections`.
- Added support for Collection Groups in Firestore


## 1.2.2

- Fixed issue with converting to JS types in startAt/startAfter/endAt/endAfter (#45).

## 1.2.1

- Added support for updating nested fields in Firestore (#44)

## 1.2.0

- Added `Query.on` and `Query.off` methods (#39).
- Added `EventType` namespace for list of all event types supported by `Query.on`.
- Added support for `FieldValue.arrayUnion` and `FieldValue.arrayRemove` in Firestore (#42).

## 1.1.0

Upgraded to support firebase-admin Node.js SDK 6.2.0 and @google-cloud/firestore 0.18.0.

Make sure to update your `package.json` with following version constraints:

```json
{
  "dependencies": {
    "firebase-admin": "~6.2.0",
    "@google-cloud/firestore": "0.18.0"
  }
}
```

Other updates:

- Added `Firestore.getAll()` method.

Note that 6.2.0 of JS SDK introduced several breaking changes to JS APIs:

- `QuerySnapshot.docChanges` is no more a field but a method `QuerySnapshot.docChanges()`.
- For query snapshots returned from `DocumentQuery.get()` all `DocumentChange`s now return their
  type as `added` instead of `null`.
- `GeoPoint` no longer exposes `toString` method.

## 1.0.0

No functional changes in this version, it is published to replace obsolete 0.0.1 version on
the Pub's package homepage to improve discoverability.

Ongoing work will continue in 1.0.0-dev.* branch until it's considered stable and feature complete.
Make sure to checkout recent dev version for latest updates.

Non-breaking changes may be published to the stable track periodically.

Other updates:

- Brought back dependency on `quiver_hashcode` (2.0.0) and removed copy-pasted implementation.

## 1.0.0-dev.24.0

- Added `Firestore.getCollections`.
- Added `DocumentReference.getCollections`.
- Added `CollectionReference.id` and `CollectionReference.path`.

## 1.0.0-dev.23.0

- Fixed Firestore queries with `GeoPoint` and `Blob` arguments.

## 1.0.0-dev.22.0

- Fixed Firestore queries with `Timestamp`s. (#35)

## 1.0.0-dev.21.0

- Upgraded to latest node_interop and fixed declaration of `FirebaseError` class.

## 1.0.0-dev.20.0

This version introduces several fixes and breaking changes related to Firestore Timestamps.
It also should be compatible with latest build_runner (1.0.0) and build_node_compilers (0.2.0).

Users are encouraged to start migrating to use Firestore Timestamps instead of DateTime objects
as soon as possible. Read "Firestore Timestamps migration" in README.md for more details.

- Added: Firestore DocumentReference.parent (#30).
- Added: Firestore `Timestamp` type.
- Added: `FirestoreSettings` type and `Firestore.settings()` method which allows to control
    `timestampsInSnapshots` option for migration to new timestamps.
- Breaking: DocumentSnapshot.createTime and DocumentSnapshot.updateTime now return an instance of new
    `Timestamp` type.
- Deprecated: `DocumentData.setDateTime` and `DocumentData.getDateTime` are deprecated in favor of
    `setTimestamp` and `getTimestamp` accordingly.

## 1.0.0-dev.19.0

- Temporarily removed dependency and copied hash functions from quiver_hashcode until it supports
  Dart 2 stable.

## 1.0.0-dev.18.0

- Fixed: analysis warnings with latest Pub and Dart SDK, prepare for Dart 2 stable.

## 1.0.0-dev.17.0

- Added: complex types support to Firestore lists
- Breaking: removed generic type argument from `DocumentData.setList`
  and `DocumentData.getList` methods. Firestore does not enforce single
  type to all elements in a list, so having generic type on those
  methods was limiting.

## 1.0.0-dev.16.0

- Fixed: strong mode errors with latest Dart 2 SDK (dev.68).

## 1.0.0-dev.15.0

- Added: `Firestore.runTransaction`
- Breaking: Firestore `DocumentSnapshot.updateTime` type changed to
    `String` from `DateTime`. This field contains ISO formatted datetime
    string with nanosecond precision and can't be converted to Dart's
    `DateTime` object without loosing information (`DateTime` only
    stores microseconds). This value should be treated as opaque when
    passed to any transaction as a precondition.
- Fixed: dartdevc build by upgrading to latest build_runner.

## 1.0.0-dev.14.0

- Fixed: Firestore, fixed error calling `CollectionReference.document()`
    without arguments.
- Fixed: Firestore, fixed error calling `DocumentQuery.where()` with
    `DocumentReference` as value.

## 1.0.0-dev.13.0

- Added: Firestore, support for `SetOptions` and `WriteBatch` (#14).

## 1.0.0-dev.12.0

- Added: Firestore, support for Blob fields (#13).

## 1.0.0-dev.11.0

- Fixed: Firestore, QuerySnapshot.documentChanges was wrongly testing for
    isEmpty (#11).

## 1.0.0-dev.10.0

- Added: Firestore, support for `select`, `offset`, `startAt`,
    `startAfter`, `endAt`, `endBefore`, `FieldValue.delete` and
    `FieldValue.timestamp` (#8).
- Deprecated: Firestore, deprecated `createGeoPoint` and `createFieldPath`
    functions. These will be hidden from public API before stable
    `1.0.0` release.
- Added: Firestore, `Firestore.documentId()` function as a
    replacement for the library-level `documentId()` function.
    The library-level function is now deprecated and will be removed
    before stable `1.0.0` release.

## 1.0.0-dev.9.0

- Upgraded to JS sdk v5.11.0
- `FirebaseAdmin.initializeApp` can now be invoked without explicit
  credentials, in which case the app will be initialized with Google
  Application Default Credentials (introduced in JS SDK v5.9.1).

## 1.0.0-dev.8.0

- Fixed: GeoPoint treated as invalid type when used in Firebase Functions.

## 1.0.0-dev.7.0

- Added: Firebase Database `Reference.transaction` method.

## 1.0.0-dev.6.0

- Added: following methods to Firebase `Query`: `ref`, `endAt`, `equalTo`,
  `isEqual`, `limitToFirst`, `limitToLast`, `orderByChild`, `orderByKey`,
  `orderByPriority`, `orderByValue`, `startAt`, `toJson`, `toString`.
- Added: Firebase Database `Reference.update` method.

## 1.0.0-dev.5.0

- Added: Auth service implementation. See `App.auth()` method and `Auth` class
  for more details.

## 1.0.0-dev.4.0

- Breaking change: `CollectionReference.add` now expects instance of
  `DocumentData` instead of regular Dart `Map`. Use `DocumentData.fromMap` to
  upgrade from previous version.
- Fixed: Handle nested maps in `DocumentData.fromMap`.

## 1.0.0-dev.3.0

- Added: Firestore `DocumentData.keys` and `DocumentData.toMap()`.

## 1.0.0-dev.2.0

- Fixed: `DocumentQuery.snapshots` was subscribing to a wrong stream of updates.
- Added: `DocumentQuery.get`.

## 1.0.0-dev.1.0

- Breaking change: Depends on Dart SDK >= 2.0.0-dev.
- Breaking change: Depends on node_interop >= 1.0.0-dev.
- Breaking change: removed built_value integration.
- Added: Firestore support.
- Internal: run tests in both dart2js and dartdevc.
- Updated documentation with new instructions.

## 0.1.0-beta.4

- Breaking: `FirebaseAdmin.initializeApp()` now expects new `AppOptions`
    object as the first argument and optional `name` argument. See documentation
    for `FirebaseAdmin.initializeApp()` for more details and example.

## 0.1.0-beta.3

- Updated JS bindings with type arguments for Promises.

## 0.1.0-beta.2

- **New:** Preliminary support for [built_value](https://pub.dartlang.org/packages/built_value) models and serializers.
- **Breaking:** Removed `Js` prefix for interface classes.
- **Breaking:** `Credential` got split in to `CredentialService` and
  `Credential`. Similar changes with `Database` and `DatabaseService`.
- Upgraded to `node_interop: 0.1.0-beta.4`.
- Consolidated all JS bindings in to one file.
- Completed interface bindings for Realtime Database.
- Added interface bindings for Firestore.
- Many dartdoc updates for JS bindings.

## 0.1.0-beta.1

- Breaking change: `FirebaseAdmin.initializeApp()` now accepts separate named
    arguments for credential and databaseURL
- Breaking change: `Credential.cert()` now accepts separate named arguments
    for service account key parameters
- New `Credential.certFromPath()` method added.
- Added `DataSnapshot.forEach()`.
- Many dartdoc updates
- Updated to node_interop `0.1.0-beta.1`

## 0.0.1

- Initial version
