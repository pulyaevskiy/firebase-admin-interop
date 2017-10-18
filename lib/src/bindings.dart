// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
@JS()
library firebase_admin;

import 'dart:js';

import 'package:firestore_interop/firestore_interop.dart';
import 'package:js/js.dart';
import 'package:node_interop/node_interop.dart';

export 'package:firestore_interop/firestore_interop.dart'
    show Firestore, FieldPath, FieldValue, GeoPoint;

void initFirebaseAdmin() {
  if (context.hasProperty('FirebaseAdmin')) return;
  context['FirebaseAdmin'] = context.callMethod('require', ['firebase-admin']);
}

// admin =======================================================================

const defaultAppName = '[DEFAULT]';

/// Creates and initializes a Firebase app instance.
@JS('FirebaseAdmin.initializeApp')
external App initializeApp(options, [String name]);

/// The current SDK version.
@JS('FirebaseAdmin.SDK_VERSION')
external String get SDK_VERSION;

/// A (read-only) array of all initialized apps.
@JS('FirebaseAdmin.apps')
external List<App> get apps;

/// Retrieves a Firebase [App] instance.
///
/// When called with no arguments, the default app is returned. When an app
/// [name] is provided, the app corresponding to that name is returned.
///
/// An exception is thrown if the app being retrieved has not yet been
/// initialized.
@JS('FirebaseAdmin.app')
external App app([String name]);

/// Gets the [Database] service for the default app or a given [app].
@JS('FirebaseAdmin.database')
external Database database([App app]);

/// Gets the [Firestore] client for the default app or a given [app].
@JS('FirebaseAdmin.firestore')
external Firestore firestore([App app]);

@JS('FirebaseAdmin.FirebaseError')
abstract class FirebaseError extends JsError {}

@JS('FirebaseAdmin.FirebaseArrayIndexError')
abstract class FirebaseArrayIndexError {
  external FirebaseError get error;
  external num get index;
}

// admin.credential ============================================================

/// Returns a [Credential] created from the Google Application Default
/// Credentials (ADC) that grants admin access to Firebase services.
///
/// This credential can be used in the call to [initializeApp].
@JS('FirebaseAdmin.credential.applicationDefault')
external Credential applicationDefaultCredential();

/// Returns [Credential] created from the provided service account that grants
/// admin access to Firebase services.
///
/// This credential can be used in the call to [initializeApp].
/// [credentials] must be a path to a service account key JSON file or an
/// object representing a service account key.
@JS('FirebaseAdmin.credential.cert')
external Credential cert(credentials);

/// Returns [Credential] created from the provided refresh token that grants
/// admin access to Firebase services.
///
/// This credential can be used in the call to [initializeApp].
@JS('FirebaseAdmin.credential.refreshToken')
external Credential refreshToken(refreshTokenPathOrObject);

@JS()
@anonymous
abstract class ServiceAccountConfig {
  external String get project_id;
  external String get client_email;
  external String get private_key;

  external factory ServiceAccountConfig(
      {String project_id, String client_email, String private_key});
}

/// Interface which provides Google OAuth2 access tokens used to authenticate
/// with Firebase services.
@JS('FirebaseAdmin.credential.Credential')
abstract class Credential {
  /// Returns a Google OAuth2 [AccessToken] object used to authenticate with
  /// Firebase services.
  external AccessToken getAccessToken();
}

/// Google OAuth2 access token object used to authenticate with Firebase
/// services.
@JS()
@anonymous
abstract class AccessToken {
  /// The actual Google OAuth2 access token.
  external String get access_token;

  /// The number of seconds from when the token was issued that it expires.
  external num get expires_in;
}

// admin.app ===================================================================

/// A Firebase app holds the initialization information for a collection of
/// services.
@JS('FirebaseAdmin.app.App')
abstract class App {
  /// The name for this app.
  ///
  /// The default app's name is `[DEFAULT]`.
  external String get name;

  /// The (read-only) configuration options for this app. These are the original
  /// parameters given in [initializeApp].
  external AppOptions get options;

  /// Gets the [Auth] service for this app.
  external Auth auth();

  /// Gets the [Database] service for this app.
  external Database database();

  /// Renders this app unusable and frees the resources of all associated
  /// services.
  external Promise delete();

  /// Gets the [Firestore] client for this app.
  external Firestore firestore();
}

/// Available options to pass to [initializeApp].
@JS('FirebaseAdmin.app.AppOptions')
@anonymous
abstract class AppOptions {
  /// A [Credential] object used to authenticate the Admin SDK.
  ///
  /// You can obtain a credential via one of the following methods:
  ///
  /// - [applicationDefaultCredential]
  /// - [cert]
  /// - [refreshToken]
  external Credential get credential;

  /// The URL of the Realtime Database from which to read and write data.
  external String get databaseURL;

  /// The ID of the Google Cloud project associated with the App.
  external String get projectId;

  /// The name of the default Cloud Storage bucket associated with the App.
  external String get storageBucket;

  /// Creates new instance of [AppOptions].
  external factory AppOptions({
    Credential credential,
    String databaseURL,
    String projectId,
    String storageBucket,
  });
}

// admin.auth ==================================================================

/// The Firebase Auth service interface.
@JS()
abstract class Auth {
  // TODO: add definitions for Auth interface.
}

// admin.database ==============================================================

/// A placeholder value for auto-populating the current timestamp (time since
/// the Unix epoch, in milliseconds) as determined by the Firebase servers.
@JS('FirebaseAdmin.database.ServerValue')
external ServerValue get databaseServerValue;

@JS()
@anonymous
abstract class ServerValue {
  external num get TIMESTAMP;
}

/// Logs debugging information to the console.
@JS('FirebaseAdmin.database.enableLogging')
external databaseEnableLogging([dynamic logger, bool persistent]);

/// The Firebase Database interface.
///
/// Access via [database].
@JS('FirebaseAdmin.database.Database')
abstract class Database {
  /// The app associated with this Database instance.
  external App get app;

  /// Disconnects from the server (all Database operations will be completed
  /// offline).
  external void goOffline();

  /// Reconnects to the server and synchronizes the offline Database state with
  /// the server state.
  external void goOnline();

  /// Returns a [Reference] representing the location in the Database
  /// corresponding to the provided [path]. If no path is provided, the
  /// Reference will point to the root of the Database.
  external Reference ref([String path]);

  /// Returns a Reference representing the location in the Database
  /// corresponding to the provided Firebase URL.
  external Reference refFromURL(String url);
}

/// A Reference represents a specific location in your [Database] and can be
/// used for reading or writing data to that Database location.
@JS('FirebaseAdmin.database.Reference')
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

  /// Returns an [OnDisconnect] object.
  ///
  /// For more information on how to use it see
  /// [Enabling Offline Capabilities in JavaScript](https://firebase.google.com/docs/database/web/offline-capabilities).
  external OnDisconnect onDisconnect();

  /// Generates a new child location using a unique key and returns its
  /// [Reference].
  ///
  /// This is the most common pattern for adding data to a collection of items.
  ///
  /// If you provide a [value] to `push()`, the value will be written to the
  /// generated location. If you don't pass a value, nothing will be written to
  /// the Database and the child will remain empty (but you can use the
  /// [Reference] elsewhere).
  ///
  /// The unique key generated by this method are ordered by the current time,
  /// so the resulting list of items will be chronologically sorted. The keys
  /// are also designed to be unguessable (they contain 72 random bits of
  /// entropy).
  external ThenableReference<Null> push([value, onComplete(JsError error)]);

  /// Removes the data at this Database location.
  ///
  /// Any data at child locations will also be deleted.
  ///
  /// The effect of the remove will be visible immediately and the corresponding
  /// event 'value' will be triggered. Synchronization of the remove to the
  /// Firebase servers will also be started, and the returned [Promise] will
  /// resolve when complete. If provided, the [onComplete] callback will be
  /// called asynchronously after synchronization has finished.
  external Promise remove([onComplete(JsError error)]);

  /// Writes data to this Database location.
  ///
  /// This will overwrite any data at this location and all child locations.
  ///
  /// The effect of the write will be visible immediately, and the corresponding
  /// events ("value", "child_added", etc.) will be triggered. Synchronization
  /// of the data to the Firebase servers will also be started, and the returned
  /// [Promise] will resolve when complete. If provided, the [onComplete]
  /// callback will be called asynchronously after synchronization has finished.
  ///
  /// Passing `null` for the new value is equivalent to calling [remove];
  /// namely, all data at this location and all child locations will be deleted.
  ///
  /// [set] will remove any priority stored at this location, so if priority is
  /// meant to be preserved, you need to use [setWithPriority] instead.
  ///
  /// Note that modifying data with [set] will cancel any pending transactions
  /// at that location, so extreme care should be taken if mixing [set] and
  /// [transaction] to modify the same data.
  ///
  /// A single [set] will generate a single "value" event at the location where
  /// the `set()` was performed.
  external Promise set(value, [onComplete(JsError error)]);

  /// Sets a priority for the data at this Database location.
  ///
  /// Applications need not use priority but can order collections by ordinary
  /// properties.
  ///
  /// See also:
  /// - [Sorting and filtering data](https://firebase.google.com/docs/database/web/lists-of-data#sorting_and_filtering_data)
  external Promise setPriority(priority, [onComplete(JsError error)]);

  /// Writes data the Database location. Like [set] but also specifies the
  /// [priority] for that data.
  ///
  /// Applications need not use priority but can order collections by ordinary
  /// properties.
  ///
  /// See also:
  /// - [Sorting and filtering data](https://firebase.google.com/docs/database/web/lists-of-data#sorting_and_filtering_data)
  external Promise setWithPriority(value, priority,
      [onComplete(JsError error)]);
}

@JS('FirebaseAdmin.database.ThenableReference')
abstract class ThenableReference<T> extends Reference implements Promise<T> {}

/// Allows you to write or clear data when your client disconnects from the
/// [Database] server. These updates occur whether your client disconnects
/// cleanly or not, so you can rely on them to clean up data even if a
/// connection is dropped or a client crashes.
///
/// This class is most commonly used to manage presence in applications where it
/// is useful to detect how many clients are connected and when other clients
/// disconnect. See [Enabling Offline Capabilities in JavaScript](https://firebase.google.com/docs/database/web/offline-capabilities)
/// for more information.
///
/// To avoid problems when a connection is dropped before the requests can be
/// transferred to the Database server, these functions should be called before
/// any data is written.
///
/// Note that `onDisconnect` operations are only triggered once. If you want an
/// operation to occur each time a disconnect occurs, you'll need to
/// re-establish the onDisconnect operations each time you reconnect.
@JS('FirebaseAdmin.database.OnDisconnect')
abstract class OnDisconnect {
  /// Cancels all previously queued `onDisconnect()` set or update events for
  /// this location and all children.
  ///
  /// If a write has been queued for this location via a [set] or [update] at a
  /// parent location, the write at this location will be canceled, though all
  /// other siblings will still be written.
  ///
  /// Optional [onComplete] function that will be called when synchronization to
  /// the server has completed. The callback will be passed a single parameter:
  /// `null` for success, or a [JsError] object indicating a failure.
  external Promise cancel([onComplete(JsError error)]);

  /// Ensures the data at this location is deleted when the client is
  /// disconnected (due to closing the browser, navigating to a new page, or
  /// network issues).
  ///
  /// Optional [onComplete] function that will be called when synchronization to
  /// the server has completed. The callback will be passed a single parameter:
  /// `null` for success, or a [JsError] object indicating a failure.
  external Promise remove([onComplete(JsError error)]);

  /// Ensures the data at this location is set to the specified [value] when the
  /// client is disconnected (due to closing the browser, navigating to a new
  /// page, or network issues).
  ///
  /// [set] is especially useful for implementing "presence" systems, where a
  /// value should be changed or cleared when a user disconnects so that they
  /// appear "offline" to other users.
  ///
  /// Optional [onComplete] function that will be called when synchronization to
  /// the server has completed. The callback will be passed a single parameter:
  /// `null` for success, or a [JsError] object indicating a failure.
  ///
  /// See also:
  /// - [Enabling Offline Capabilities in JavaScript](https://firebase.google.com/docs/database/web/offline-capabilities)
  external Promise set(value, [onComplete(JsError error)]);

  /// Ensures the data at this location is set to the specified [value] and
  /// [priority] when the client is disconnected (due to closing the browser,
  /// navigating to a new page, or network issues).
  external Promise setWithPriority(value, priority,
      [onComplete(JsError error)]);

  /// Writes multiple [values] at this location when the client is disconnected
  /// (due to closing the browser, navigating to a new page, or network issues).
  ///
  /// The [values] argument contains multiple property-value pairs that will be
  /// written to the Database together. Each child property can either be a
  /// simple property (for example, "name") or a relative path (for example,
  /// "name/first") from the current location to the data to update.
  ///
  /// As opposed to the [set] method, [update] can be use to selectively update
  /// only the referenced properties at the current location (instead of
  /// replacing all the child properties at the current location).
  ///
  /// See [Reference.update] for examples of using the connected version of
  /// update.
  external Promise update(values, [onComplete(JsError error)]);
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
@JS('FirebaseAdmin.database.Query')
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

/// Contains data from a Database location.
///
/// Any time you read data from the Database, you receive the data as a
/// [DataSnapshot]. A DataSnapshot is passed to the event callbacks you attach
/// with [Reference.on] or [Reference.once]. You can extract the contents of the
/// snapshot as a JavaScript object by calling the [val] method. Alternatively,
/// you can traverse into the snapshot by calling [child] to return child
/// snapshots (which you could then call [val] on).
///
/// A DataSnapshot is an efficiently generated, immutable copy of the data at a
/// Database location. It cannot be modified and will never change (to modify
/// data, you always call the [set] method on a [Reference] directly).
@JS('FirebaseAdmin.database.DataSnapshot')
abstract class DataSnapshot {
  /// The key (last part of the path) of the location of this DataSnapshot.
  ///
  /// The last token in a Database location is considered its key. For example,
  /// "ada" is the key for the `/users/ada/` node. Accessing the key on any
  /// DataSnapshot will return the key for the location that generated it.
  /// However, accessing the key on the root URL of a Database will return
  /// `null`.
  external String get key;

  /// The [Reference] for the location that generated this DataSnapshot.
  external Reference get ref;

  /// Gets another DataSnapshot for the location at the specified relative
  /// [path].
  ///
  /// Passing a relative path to the [child] method of a DataSnapshot returns
  /// another DataSnapshot for the location at the specified relative path. The
  /// relative [path] can either be a simple child name (for example, "ada") or
  /// a deeper, slash-separated path (for example, "ada/name/first"). If the
  /// child location has no data, an empty DataSnapshot (that is, a DataSnapshot
  /// whose value is `null`) is returned.
  external DataSnapshot child(String path);

  /// Returns `true` if this DataSnapshot contains any data.
  ///
  /// It is slightly more efficient than using `snapshot.val() != null`.
  external bool exists();

  /// Exports the entire contents of the DataSnapshot as a JavaScript object.
  ///
  /// The [exportVal] method is similar to [val], except priority information is
  /// included (if available), making it suitable for backing up your data.
  external dynamic exportVal();

  /// Enumerates the top-level children in this DataSnapshot.
  ///
  /// The [action] function is called for each child DataSnapshot. The callback
  /// can return `true` to cancel further enumeration.
  ///
  /// This method returns `true` if enumeration was canceled due to your
  /// callback returning true.
  ///
  /// Because of the way JavaScript objects work, the ordering of data in the
  /// JavaScript object returned by [val] is not guaranteed to match the
  /// ordering on the server nor the ordering of child_added events. That is
  /// where [forEach] comes in handy. It guarantees the children of a
  /// DataSnapshot will be iterated in their query order.
  ///
  /// If no explicit `orderBy*()` method is used, results are returned ordered
  /// by key (unless priorities are used, in which case, results are returned by
  /// priority).
  external bool forEach(bool action(DataSnapshot child));

  /// Gets the priority value of the data in this DataSnapshot.
  ///
  /// Applications need not use priority but can order collections by ordinary
  /// properties.
  ///
  /// See also:
  /// - [Sorting and filtering data](https://firebase.google.com/docs/database/web/lists-of-data#sorting_and_filtering_data)
  external dynamic getPriority();

  /// Returns `true` if the specified child [path] has (non-null) data.
  external bool hasChild(String path);

  /// Returns whether or not this DataSnapshot has any non-null child
  /// properties.
  ///
  /// You can use [hasChildren] to determine if a DataSnapshot has any children.
  /// If it does, you can enumerate them using [forEach]. If it doesn't, then
  /// either this snapshot contains a primitive value (which can be retrieved
  /// with [val]) or it is empty (in which case, [val] will return `null`).
  external bool hasChildren();

  /// Returns the number of child properties of this DataSnapshot.
  external num numChildren();

  /// Returns a JSON-serializable representation of this object.
  external dynamic toJSON();

  /// Extracts a JavaScript value from this DataSnapshot.
  ///
  /// Depending on the data in a DataSnapshot, the [val] method may return a
  /// scalar type (string, number, or boolean), an array, or an object. It may
  /// also return `null`, indicating that the DataSnapshot is empty (contains
  /// no data).
  external dynamic val();
}
