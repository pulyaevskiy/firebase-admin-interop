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
