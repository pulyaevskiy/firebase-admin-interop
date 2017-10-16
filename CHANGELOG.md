# Changelog

## 0.1.0-beta.2

- Upgraded to `node_interop: 0.1.0-beta.3`.
- Consolidated all JS bindings in to one file.
- Completed interface bindings for Realtime Database.
- Added interface bindings for Firestore.
- Many dartdoc updates for JS bindings.
- Breaking: Removed `Js` prefix for interface classes.
- Breaking: `Credential` got split in to `CredentialService` and
  `Credential`. Similar changes with `Database` and `DatabaseService`.

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
