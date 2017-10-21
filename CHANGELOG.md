# Changelog

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
