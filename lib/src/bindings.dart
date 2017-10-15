// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
@JS()
library firebase_admin_interop.bindings;

import 'package:js/js.dart';
import 'package:node_interop/node_interop.dart';

FirebaseAdmin requireFirebaseAdmin() => require('firebase-admin');

/// Global namespace from which all the Firebase Admin services are accessed.
///
/// Access via [requireFirebaseAdmin].
@JS()
abstract class FirebaseAdmin {
  /// The current SDK version.
  external static String get SDK_VERSION;

  /// A (read-only) array of all initialized apps.
  external List<App> get apps;

  /// Credential service used by Firebase.
  external Credential get credential;

  /// Retrieves a Firebase app instance.
  ///
  /// When called with no arguments, the default app is returned. When an app
  /// name is provided, the app corresponding to that name is returned.
  ///
  /// An exception is thrown if the app being retrieved has not yet been
  /// initialized.
  external App app([String name]);

  /// Creates and initializes a Firebase app instance.
  external App initializeApp(AppOptions options, [String name]);

  /// Gets the [Database] service for the default app or a given [app].
  external Database database([App app]);
}

@JS()
@anonymous
abstract class ServiceAccountConfig {
  external String get project_id;
  external String get client_email;
  external String get private_key;

  external factory ServiceAccountConfig(
      {String project_id, String client_email, String private_key});
}

@JS()
abstract class App {
  external String get name;
  external Database database();
  external Promise delete();
}

@JS()
@anonymous
abstract class AppOptions {
  external Credential get credential;
  external String get databaseURL;
  external factory AppOptions({Credential credential, String databaseURL});
}

/// Interface which provides Google OAuth2 access tokens used to authenticate
/// with Firebase services.
@JS()
abstract class Credential {
  external AccessToken getAccessToken();

  /// Returns a credential created from the Google Application Default
  /// Credentials that grants admin access to Firebase services.
  ///
  /// This credential can be used in the call to [FirebaseAdmin.initializeApp].
  external /* static */ Credential applicationDefault();

  /// Returns a credential created from the provided service account that grants
  /// admin access to Firebase services.
  ///
  /// This credential can be used in the call to [FirebaseAdmin.initializeApp].
  /// [credentials] must be a path to a service account key JSON file or an
  /// object representing a service account key.
  external /* static */ Credential cert(credentials);

  /// Returns a credential created from the provided refresh token that grants
  /// admin access to Firebase services.
  ///
  /// This credential can be used in the call to [FirebaseAdmin.initializeApp].
  external /* static */ Credential refreshToken(refreshTokenPathOrObject);
}

@JS()
abstract class AccessToken {
  external String get access_token;
  external num get expires_in;
}

/// The Firebase Database service interface.
///
/// Access via [FirebaseAdmin.database].
@JS()
abstract class Database {
  /// The app associated with this Database service instance.
  external App get app;
  /// A placeholder value for auto-populating the current timestamp (time since
  /// the Unix epoch, in milliseconds) as determined by the Firebase servers.
  external /* static */ ServerValues get ServerValue;
  /// Logs debugging information to the console.
  external /* static */ enableLogging([dynamic logger, bool persistent]);

  /// Disconnects from the server (all Database operations will be completed
  /// offline).
  external goOffline();

  /// Reconnects to the server and synchronizes the offline Database state with
  /// the server state.
  external goOnline();

  /// Returns a [Reference] representing the location in the Database
  /// corresponding to the provided [path]. If no path is provided, the
  /// Reference will point to the root of the Database.
  external Reference ref([String path]);

  /// Returns a Reference representing the location in the Database
  /// corresponding to the provided Firebase URL.
  external Reference refFromURL(String url);
}

@JS()
abstract class ServerValues {
  external num get TIMESTAMP;
}

/// A Reference represents a specific location in your [Database] and can be
/// used for reading or writing data to that Database location.
@JS()
abstract class Reference {
  /// The last part of this Reference's path.
  ///
  /// For example, "ada" is the key for `https://<DB>.firebaseio.com/users/ada`.
  /// The key of a root [Reference] is `null`.
  external String get key;
  /// The parent location of this Reference.
  ///
  /// The parent of a root Reference is `null`.
  external Reference get parent;
  external Reference get root;
  external Reference child(String path);
  external Promise once(String eventType,
      [successCallback, failureCallbackOrContext, context]);
  external Promise set(value, [onComplete]);
}

@JS()
abstract class DataSnapshot {
  external String get key;
  external Reference get ref;
  external DataSnapshot child(String path);
  external bool exists();
  external dynamic exportVal();
  external bool forEach(bool action(DataSnapshot child));
  external dynamic getPriority();
  external bool hasChild(String path);
  external bool hasChildren();
  external int numChildren();
  external dynamic val();
}
