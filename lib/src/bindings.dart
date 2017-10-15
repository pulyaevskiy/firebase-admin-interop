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
  external CredentialService get credential;

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
abstract class CredentialService {
  /// Returns a [Credential] created from the Google Application Default
  /// Credentials that grants admin access to Firebase services.
  ///
  /// This credential can be used in the call to [FirebaseAdmin.initializeApp].
  external Credential applicationDefault();

  /// Returns [Credential] created from the provided service account that grants
  /// admin access to Firebase services.
  ///
  /// This credential can be used in the call to [FirebaseAdmin.initializeApp].
  /// [credentials] must be a path to a service account key JSON file or an
  /// object representing a service account key.
  external Credential cert(credentials);

  /// Returns [Credential] created from the provided refresh token that grants
  /// admin access to Firebase services.
  ///
  /// This credential can be used in the call to [FirebaseAdmin.initializeApp].
  external Credential refreshToken(refreshTokenPathOrObject);
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
  /// Returns a Google OAuth2 [AccessToken] object used to authenticate with
  /// Firebase services.
  external AccessToken getAccessToken();
}

/// Google OAuth2 access token object used to authenticate with Firebase
/// services.
@JS()
abstract class AccessToken {
  /// The actual Google OAuth2 access token.
  external String get access_token;

  /// The number of seconds from when the token was issued that it expires.
  external num get expires_in;
}

// TODO: Wait until https://github.com/dart-lang/sdk/issues/30969 is resolved.
@JS()
abstract class DatabaseService {
  /// A placeholder value for auto-populating the current timestamp (time since
  /// the Unix epoch, in milliseconds) as determined by the Firebase servers.
  external ServerValues get ServerValue;

  /// Logs debugging information to the console.
  external enableLogging([dynamic logger, bool persistent]);
}

/// The Firebase Database service interface.
///
/// Access via [FirebaseAdmin.database].
@JS()
abstract class Database {
  /// The app associated with this Database service instance.
  external App get app;

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
abstract class Reference extends Query {
  /// The last part of this Reference's path.
  ///
  /// For example, "ada" is the key for `https://<DB>.firebaseio.com/users/ada`.
  /// The key of a root [Reference] is `null`.
  external String get key;

  /// The parent location of this Reference.
  ///
  /// The parent of a root Reference is `null`.
  external Reference get parent;

  /// The root `Reference` of the [Database].
  external Reference get root;

  /// Gets a `Reference` for the location at the specified relative [path].
  ///
  /// The relative [path] can either be a simple child name (for example, "ada")
  /// or a deeper slash-separated path (for example, "ada/name/first").
  external Reference child(String path);

  external Promise set(value, [onComplete]);
}

/// Sorts and filters the data at a [Database] location so only a subset of the
/// child data is included.
///
/// This can be used to order a collection of data by some attribute (for
/// example, height of dinosaurs) as well as to restrict a large list of items
/// (for example, chat messages) down to a number suitable for synchronizing to
/// the client. Queries are created by chaining together one or more of the
/// filter methods defined here.
///
/// Just as with a [Reference], you can receive data from a [Query] by using
/// the [on] method. You will only receive events and [DataSnapshot]s for the
/// subset of the data that matches your query.
///
/// See also:
///   - [Sorting and filtering data](https://firebase.google.com/docs/database/web/lists-of-data#sorting_and_filtering_data)
@JS()
abstract class Query {
  /// Returns a `Reference` to the [Query]'s location.
  external Reference get ref;

  /// Creates a [Query] with the specified ending point.
  ///
  /// Using [startAt], [endAt], and [equalTo] allows you to choose arbitrary
  /// starting and ending points for your queries.
  /// The ending point is inclusive, so children with exactly the specified
  /// value will be included in the query. The optional key argument can be used
  /// to further limit the range of the query. If it is specified, then children
  /// that have exactly the specified value must also have a key name less than
  /// or equal to the specified key.
  ///
  /// The [value] type depends on which `orderBy*()` function was used in this
  /// query. Specify a value that matches the `orderBy*()` type. When used in
  /// combination with [orderByKey], the value must be a `String`.
  ///
  /// Optional [key] is only allowed if ordering by priority and defines the
  /// child key to end at, among the children with the previously specified
  /// priority.
  external Query endAt(dynamic value, [String key]);

  /// Creates a [Query] that includes children that match the specified value.
  ///
  /// Using [startAt], [endAt], and [equalTo] allows you to choose arbitrary
  /// starting and ending points for your queries.
  ///
  /// The [value] type depends on which `orderBy*()` function was used in this
  /// query. Specify a value that matches the `orderBy*()` type. When used in
  /// combination with [orderByKey], the value must be a `String`.
  ///
  /// The optional [key] argument can be used to further limit the range of the
  /// query. If it is specified, then children that have exactly the specified
  /// value must also have exactly the specified key as their key name. This can
  /// be used to filter result sets with many matches for the same value.
  external Query equalTo(dynamic value, [String key]);

  /// Returns `true` if this and [other] query are equal.
  ///
  /// Returns whether or not the current and provided queries represent the same
  /// location, have the same query parameters, and are from the same instance
  /// of [App]. Equivalent queries share the same sort order, limits, and
  /// starting and ending points.
  ///
  /// Two [Reference] objects are equivalent if they represent the same location
  /// and are from the same instance of [App].
  external bool isEqual(Query other);

  /// Generates a new [Query] limited to the first specific number of children.
  ///
  /// This method is used to set a maximum number of children to be synced for a
  /// given callback. If we set a limit of 100, we will initially only receive
  /// up to 100 child_added events. If we have fewer than 100 messages stored in
  /// our [Database], a child_added event will fire for each message. However,
  /// if we have over 100 messages, we will only receive a child_added event for
  /// the first 100 ordered messages. As items change, we will receive
  /// child_removed events for each item that drops out of the active list so
  /// that the total number stays at 100.
  external Query limitToFirst(num limit);

  /// Generates a new [Query] limited to the last specific number of children.
  ///
  /// This method is used to set a maximum number of children to be synced for a
  /// given callback. If we set a limit of 100, we will initially only receive
  /// up to 100 child_added events. If we have fewer than 100 messages stored in
  /// our Database, a child_added event will fire for each message. However, if
  /// we have over 100 messages, we will only receive a child_added event for
  /// the last 100 ordered messages. As items change, we will receive
  /// child_removed events for each item that drops out of the active list so
  /// that the total number stays at 100.
  external Query limitToLast(num limit);

  /// Detaches a callback previously attached with [on].
  ///
  /// Note that if [on] was called multiple times with the same [eventType] and
  /// [callback], the callback will be called multiple times for each event, and
  /// [off] must be called multiple times to remove the callback. Calling [off]
  /// on a parent listener will not automatically remove listeners registered on
  /// child nodes, [off] must also be called on any child listeners to remove
  /// the callback.
  ///
  /// If a [callback] is not specified, all callbacks for the specified
  /// [eventType] will be removed. Similarly, if no [eventType] or [callback] is
  /// specified, all callbacks for the [Reference] will be removed.
  external void off([String eventType, callback, context]);

  /// Listens for data changes at a particular location.
  ///
  /// This is the primary way to read data from a [Database]. Your callback will
  /// be triggered for the initial data and again whenever the data changes.
  /// Use [off] to stop receiving updates.
  external void on(String eventType, callback,
      [cancelCallbackOrContext, context]);

  /// Listens for exactly one event of the specified [eventType], and then stops
  /// listening.
  ///
  /// This is equivalent to calling [on], and then calling [off] inside the
  /// callback function. See [on] for details on the event types.
  external Promise once(String eventType,
      [successCallback, failureCallbackOrContext, context]);

  /// Generates a new [Query] object ordered by the specified child key.
  ///
  /// Queries can only order by one key at a time. Calling [orderByChild]
  /// multiple times on the same query is an error.
  external Query orderByChild(String path);

  /// Generates a new [Query] object ordered by key.
  ///
  /// Sorts the results of a query by their (ascending) key values.
  ///
  /// See also:
  /// - [Sort data](https://firebase.google.com/docs/database/web/lists-of-data#sort_data)
  external Query orderByKey();

  /// Generates a new [Query] object ordered by priority.
  ///
  /// Applications need not use priority but can order collections by ordinary
  /// properties.
  ///
  /// See also:
  /// - [Sort data](https://firebase.google.com/docs/database/web/lists-of-data#sort_data)
  external Query orderByPriority();

  /// Generates a new [Query] object ordered by value.
  ///
  /// If the children of a query are all scalar values (string, number, or
  /// boolean), you can order the results by their (ascending) values.
  ///
  /// See also:
  /// - [Sort data](https://firebase.google.com/docs/database/web/lists-of-data#sort_data)
  external Query orderByValue();

  /// Creates a [Query] with the specified starting point.
  ///
  /// The starting point is inclusive, so children with exactly the specified
  /// [value] will be included in the query.
  ///
  /// The optional [key] argument can be used to further limit the range of the
  /// query. If it is specified, then children that have exactly the specified
  /// [value] must also have a `key` name greater than or equal to the specified
  /// [key].
  ///
  /// See also:
  /// - [Filtering data](https://firebase.google.com/docs/database/web/lists-of-data#filtering_data)
  external Query startAt(dynamic value, [String key]);

  /// Returns a JSON-serializable representation of this object.
  external dynamic toJSON();
  /// Gets the absolute URL for this location.
  ///
  /// Returned URL is ready to be put into a browser, curl command, or
  /// [Database.refFromURL] call. Since all of those expect the URL to be
  /// url-encoded, [toString] returns an encoded URL.
  ///
  /// Append '.json' to the returned URL when typed into a browser to download
  /// JSON-formatted data. If the location is secured (that is, not publicly
  /// readable), you will get a permission-denied error.
  external String toString();
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
