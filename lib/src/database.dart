// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:js';

import 'package:meta/meta.dart';
import 'package:node_interop/util.dart';
import 'package:node_interop/js.dart';

import 'app.dart';
import 'bindings.dart' as js;

/// Firebase Realtime Database service.
class Database {
  @protected
  final js.Database nativeInstance;

  /// The app associated with this Database instance.
  final App app;

  Database(this.nativeInstance, this.app);

  /// Disconnects from the server (all Database operations will be completed
  /// offline).
  void goOffline() => nativeInstance.goOffline();

  /// Reconnects to the server and synchronizes the offline Database state with
  /// the server state.
  void goOnline() => nativeInstance.goOnline();

  /// Returns a [Reference] representing the location in the Database
  /// corresponding to the provided [path]. If no path is provided, the
  /// Reference will point to the root of the Database.
  Reference ref([String path]) => new Reference(nativeInstance.ref(path));

  /// Returns a [Reference] representing the location in the Database
  /// corresponding to the provided Firebase URL.
  Reference refFromUrl(String url) =>
      new Reference(nativeInstance.refFromURL(url));
}

/// List of event types supported in [Query.on] and [Query.off].
abstract class EventType {
  /// This event will trigger once with the initial data stored at specific
  /// location, and then trigger again each time the data changes.
  ///
  /// It won't trigger until the entire contents has been synchronized.
  /// If the location has no data, it will be triggered with an empty
  /// DataSnapshot.
  static const String value = 'value';

  /// This event will be triggered once for each initial child at specific
  /// location, and it will be triggered again every time a new child is added.
  static const String childAdded = 'child_added';

  /// This event will be triggered once every time a child is removed.
  ///
  /// A child will get removed when either:
  ///
  /// * a client explicitly calls [Reference.remove] on that child or one of
  ///   its ancestors
  /// * a client calls [Reference.setValue] with `null` on that child or one
  ///   of its ancestors
  /// * that child has all of its children removed
  /// * there is a query in effect which now filters out the child (because
  ///   it's sort order changed or the max limit was hit)
  static const String childRemoved = 'child_removed';

  /// This event will be triggered when the data stored in a child (or any of
  /// its descendants) changes.
  ///
  /// Note that a single child_changed event may represent multiple changes to
  /// the child.
  static const String childChanged = 'child_changed';

  /// This event will be triggered when a child's sort order changes such that
  /// its position relative to its siblings changes.
  static const String childMoved = 'child_moved';
}

/// QuerySubscription to keep function callback and allowing use to unsubscribe
/// with [cancel] later.
class QuerySubscription {
  /// Type of events handled by this subscription.
  ///
  /// One of [EventType] constants.
  final String eventType;
  final js.Query _nativeInstance;
  final Function _callback;

  QuerySubscription(this.eventType, this._nativeInstance, this._callback);

  /// Cancels this subscription.
  ///
  /// Detaches the callback previously registered with [Query.on].
  ///
  /// See also [Query.off] for other ways of canceling subscriptions.
  void cancel() {
    _nativeInstance.off(this.eventType, this._callback);
  }
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
class Query {
  @protected
  final js.Query nativeInstance;

  Query(this.nativeInstance);

  /// Returns a [Reference] to the [Query]'s location.
  Reference get ref => _ref ??= new Reference(nativeInstance.ref);
  Reference _ref;

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
  Query endAt(value, [String key]) {
    if (key == null) {
      return new Query(nativeInstance.endAt(value));
    }
    return new Query(nativeInstance.endAt(value, key));
  }

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
  Query equalTo(value, [String key]) {
    if (key == null) {
      return new Query(nativeInstance.equalTo(value));
    }
    return new Query(nativeInstance.equalTo(value, key));
  }

  /// Returns `true` if this and [other] query are equal.
  ///
  /// Returns whether or not the current and provided queries represent the same
  /// location, have the same query parameters, and are from the same instance
  /// of [App]. Equivalent queries share the same sort order, limits, and
  /// starting and ending points.
  ///
  /// Two [Reference] objects are equivalent if they represent the same location
  /// and are from the same instance of [App].
  bool isEqual(Query other) => nativeInstance.isEqual(other.nativeInstance);

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
  Query limitToFirst(int limit) =>
      new Query(nativeInstance.limitToFirst(limit));

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
  Query limitToLast(int limit) => new Query(nativeInstance.limitToLast(limit));

  /// Listens for exactly one event of the specified [eventType], and then stops
  /// listening.
  Future<DataSnapshot<T>> once<T>(String eventType) {
    return promiseToFuture(nativeInstance.once(eventType))
        .then((snapshot) => new DataSnapshot(snapshot));
  }

  /// Cancels previously created subscription with [on].
  ///
  /// Calling [off] on a parent listener will not automatically remove
  /// listeners registered on child nodes, [off] must also be called on
  /// any child listeners to remove the subscription.
  ///
  /// If [eventType] is specified, all subscriptions for that specified
  /// [eventType] will be removed. If no [eventType] is
  /// specified, all callbacks for the [Reference] will be removed. If
  /// specified, [eventType] must be one of [EventType] constants.
  ///
  /// To unsubscribe a specific callback, use [QuerySubscription.cancel].
  void off([String eventType]) {
    if (eventType != null) {
      nativeInstance.off(eventType);
    } else {
      nativeInstance.off();
    }
  }

  /// Listens for data changes at a particular location.
  ///
  /// [eventType] must be one of [EventType] constants.
  ///
  /// This is the primary way to read data from a [Database]. Your callback will
  /// be triggered for the initial data and again whenever the data changes.
  /// Use [off] or [QuerySubscription.cancel] to stop receiving updates.
  ///
  /// Returns [QuerySubscription] which can be used to cancel the subscription.
  QuerySubscription on<T>(
      String eventType, Function(DataSnapshot<T> snapshot) callback,
      [Function() cancelCallback]) {
    var fn = allowInterop((snapshot) => callback(new DataSnapshot(snapshot)));
    if (cancelCallback != null) {
      nativeInstance.on(eventType, fn, allowInterop(cancelCallback));
    } else {
      nativeInstance.on(eventType, fn);
    }
    return QuerySubscription(eventType, nativeInstance, fn);
  }

  /// Generates a new [Query] object ordered by the specified child key.
  ///
  /// Queries can only order by one key at a time. Calling [orderByChild]
  /// multiple times on the same query is an error.
  Query orderByChild(String path) =>
      new Query(nativeInstance.orderByChild(path));

  /// Generates a new [Query] object ordered by key.
  ///
  /// Sorts the results of a query by their (ascending) key values.
  ///
  /// See also:
  /// - [Sort data](https://firebase.google.com/docs/database/web/lists-of-data#sort_data)
  Query orderByKey() => new Query(nativeInstance.orderByKey());

  /// Generates a new [Query] object ordered by priority.
  ///
  /// Applications need not use priority but can order collections by ordinary
  /// properties.
  ///
  /// See also:
  /// - [Sort data](https://firebase.google.com/docs/database/web/lists-of-data#sort_data)
  Query orderByPriority() => new Query(nativeInstance.orderByPriority());

  /// Generates a new [Query] object ordered by value.
  ///
  /// If the children of a query are all scalar values (string, number, or
  /// boolean), you can order the results by their (ascending) values.
  ///
  /// See also:
  /// - [Sort data](https://firebase.google.com/docs/database/web/lists-of-data#sort_data)
  Query orderByValue() => new Query(nativeInstance.orderByValue());

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
  Query startAt(value, [String key]) {
    if (key == null) {
      return new Query(nativeInstance.startAt(value));
    }
    return new Query(nativeInstance.startAt(value, key));
  }

  // Note: intentionally not following JS convention and using Dart convention instead.
  /// Returns a JSON-serializable representation of this object.
  dynamic toJson() => nativeInstance.toJSON();

  /// Gets the absolute URL for this location.
  ///
  /// Returned URL is ready to be put into a browser, curl command, or
  /// [Database.refFromURL] call. Since all of those expect the URL to be
  /// url-encoded, [toString] returns an encoded URL.
  ///
  /// Append '.json' to the returned URL when typed into a browser to download
  /// JSON-formatted data. If the location is secured (that is, not publicly
  /// readable), you will get a permission-denied error.
  @override
  String toString() => nativeInstance.toString();
}

/// A Reference represents a specific location in your [Database] and can be
/// used for reading or writing data to that Database location.
class Reference extends Query {
  Reference(js.Reference nativeInstance) : super(nativeInstance);

  @override
  @protected
  js.Reference get nativeInstance => super.nativeInstance;

  /// The last part of this Reference's path.
  ///
  /// For example, "ada" is the key for `https://<DB>.firebaseio.com/users/ada`.
  /// The key of a root [Reference] is `null`.
  String get key => nativeInstance.key;

  /// The parent location of this Reference.
  ///
  /// The parent of a root Reference is `null`.
  Reference get parent => _parent ??= new Reference(nativeInstance.parent);
  Reference _parent;

  /// The root [Reference] of the [Database].
  Reference get root => _root ??= new Reference(nativeInstance.root);
  Reference _root;

  /// Gets a [Reference] for the location at the specified relative [path].
  ///
  /// The relative [path] can either be a simple child name (for example, "ada")
  /// or a deeper slash-separated path (for example, "ada/name/first").
  Reference child(String path) => new Reference(nativeInstance.child(path));

  /// Returns an [OnDisconnect] object.
  ///
  /// For more information on how to use it see
  /// [Enabling Offline Capabilities in JavaScript](https://firebase.google.com/docs/database/web/offline-capabilities).
  dynamic onDisconnect() {
    throw new UnimplementedError();
  }

  /// Generates a new child location using a unique key and returns its
  /// [FutureReference].
  ///
  /// This is the most common pattern for adding data to a collection of items.
  ///
  /// If you provide a [value] to [push], the value will be written to the
  /// generated location. If you don't pass a value, nothing will be written to
  /// the Database and the child will remain empty (but you can use the
  /// [FutureReference] elsewhere).
  ///
  /// The unique key generated by this method are ordered by the current time,
  /// so the resulting list of items will be chronologically sorted. The keys
  /// are also designed to be unguessable (they contain 72 random bits of
  /// entropy).
  FutureReference push<T>([T value]) {
    if (value != null) {
      var futureRef = nativeInstance.push(jsify(value));
      return new FutureReference(futureRef, promiseToFuture(futureRef));
    } else {
      // JS side returns regular Reference if value is not provided, but
      // we still convert it to FutureReference to be consistent with declared
      // return type.
      var newRef = nativeInstance.push();
      return new FutureReference(newRef, new Future.value());
    }
  }

  /// Removes the data at this Database location.
  ///
  /// Any data at child locations will also be deleted.
  ///
  /// The effect of the remove will be visible immediately and the corresponding
  /// event 'value' will be triggered. Synchronization of the remove to the
  /// Firebase servers will also be started, and the returned [Future] will
  /// resolve when complete.
  Future<void> remove() => promiseToFuture(nativeInstance.remove());

  /// Writes data to this Database location.
  ///
  /// This will overwrite any data at this location and all child locations.
  ///
  /// The effect of the write will be visible immediately, and the corresponding
  /// events ("value", "child_added", etc.) will be triggered. Synchronization
  /// of the data to the Firebase servers will also be started, and the returned
  /// [Future] will resolve when complete.
  ///
  /// Passing `null` for the new value is equivalent to calling [remove];
  /// namely, all data at this location and all child locations will be deleted.
  ///
  /// [setValue] will remove any priority stored at this location, so if priority is
  /// meant to be preserved, you need to use [setWithPriority] instead.
  ///
  /// Note that modifying data with [setValue] will cancel any pending transactions
  /// at that location, so extreme care should be taken if mixing [setValue] and
  /// [transaction] to modify the same data.
  ///
  /// A single [setValue] will generate a single "value" event at the location
  /// where the `setValue()` was performed.
  Future<void> setValue<T>(T value) {
    return promiseToFuture(nativeInstance.set(jsify(value)));
  }

  /// Sets a priority for the data at this Database location.
  ///
  /// Applications need not use priority but can order collections by ordinary
  /// properties.
  ///
  /// See also:
  /// - [Sorting and filtering data](https://firebase.google.com/docs/database/web/lists-of-data#sorting_and_filtering_data)
  Future<void> setPriority(priority) =>
      promiseToFuture(nativeInstance.setPriority(priority));

  /// Writes data the Database location. Like [setValue] but also specifies the
  /// [priority] for that data.
  ///
  /// Applications need not use priority but can order collections by ordinary
  /// properties.
  ///
  /// See also:
  /// - [Sorting and filtering data](https://firebase.google.com/docs/database/web/lists-of-data#sorting_and_filtering_data)
  Future<void> setWithPriority<T>(T value, priority) {
    return promiseToFuture(
        nativeInstance.setWithPriority(jsify(value), priority));
  }

  /// Atomically modifies the data at this location.
  ///
  /// [handler] function must always return an instance of [TransactionResult]
  /// created with either [TransactionResult.abort] or [TransactionResult.success].
  ///
  ///     // Aborting a transaction
  ///     var result = await ref.transaction((currentData) {
  ///       // your logic
  ///       return TransactionResult.abort;
  ///     });
  ///
  ///     // Committing a transaction
  ///     var result = await ref.transaction((currentData) {
  ///       var data = yourUpdateDataLogic(currentData);
  ///       return TransactionResult.success(data);
  ///     });
  ///
  /// Unlike a normal [set], which
  /// just overwrites the data regardless of its previous value, [transaction]
  /// is used to modify the existing value to a new value, ensuring there are no
  /// conflicts with other clients writing to the same location at the same time.
  ///
  /// To accomplish this, you pass transaction() an update function which is used
  /// to transform the current value into a new value. If another client writes to
  /// the location before your new value is successfully written, your update
  /// function will be called again with the new current value, and the write will
  /// be retried. This will happen repeatedly until your write succeeds without
  /// conflict or you abort the transaction by returning [TransactionResult.abort].

  /// Note: Modifying data with [set] will cancel any pending transactions at that
  /// location, so extreme care should be taken if mixing set() and transaction()
  /// to update the same data.

  /// Note: When using transactions with Security and Firebase Rules in place, be
  /// aware that a client needs .read access in addition to .write access in order
  /// to perform a transaction. This is because the client-side nature of
  /// transactions requires the client to read the data in order to
  /// transactionally update it.
  Future<DatabaseTransaction> transaction<T>(
      DatabaseTransactionHandler<T> handler,
      [bool applyLocally = true]) {
    var promise = nativeInstance.transaction(
      allowInterop(_createTransactionHandler(handler)),
      allowInterop(_onComplete),
      applyLocally,
    );
    return promiseToFuture(promise).then(
      (result) {
        final jsResult = result as js.TransactionResult;
        return new DatabaseTransaction(
            jsResult.committed, new DataSnapshot(jsResult.snapshot));
      },
    );
  }

  _onComplete(error, bool committed, snapshot) {
    // no-op, we use returned Promise instead.
  }

  Function _createTransactionHandler<T>(DatabaseTransactionHandler<T> handler) {
    return (currentData) {
      final data = dartify(currentData);
      final result = handler(data);
      assert(
          result != null,
          'Transaction handler returned null and this is not allowed. '
          'Make sure to always return an instance of TransactionResult.');
      if (result.aborted) return undefined;
      return jsify(result.data);
    };
  }

  /// Writes multiple values to the Database at once.
  ///
  /// The [values] argument contains multiple property-value pairs that will be
  /// written to the Database together. Each child property can either be a simple
  /// property (for example, "name") or a relative path (for example,
  /// "name/first") from the current location to the data to update.
  ///
  /// As opposed to the [setValue] method, [update] can be used to selectively update
  /// only the referenced properties at the current location (instead of replacing
  /// all the child properties at the current location).
  ///
  /// The effect of the write will be visible immediately, and the corresponding
  /// events ('value', 'child_added', etc.) will be triggered. Synchronization of
  /// the data to the Firebase servers will also be started, and the returned
  /// `Future` will resolve when complete.
  ///
  /// A single [update] will generate a single "value" event at the location where
  /// the `update` was performed, regardless of how many children were modified.
  ///
  /// Note that modifying data with [update] will cancel any pending transactions
  /// at that location, so extreme care should be taken if mixing [update] and
  /// [transaction] to modify the same data.
  ///
  /// Passing `null` to [update] will remove the data at this location.
  Future<void> update(Map<String, dynamic> values) {
    return promiseToFuture(nativeInstance.update(jsify(values)));
  }
}

/// Interface for a Realtime Database transaction handler function used
/// in [Reference.transaction].
typedef DatabaseTransactionHandler<T> = TransactionResult<T> Function(
    T currentData);

/// Realtime Database transaction result returned from [DatabaseTransactionHandler].
///
/// Use [TransactionResult.success] and [TransactionResult.abort] to create an
/// instance of this class according to logic in your transactions.
class TransactionResult<T> {
  TransactionResult._(this.aborted, this.data);
  final bool aborted;
  final T data;

  static TransactionResult abort = new TransactionResult._(true, null);
  static TransactionResult<T> success<T>(T data) =>
      new TransactionResult._(false, data);
}

/// Firebase Realtime Database transaction result returned from
/// [Reference.transaction].
class DatabaseTransaction {
  DatabaseTransaction(this.committed, this.snapshot);

  /// Returns `true` if this transaction was committed, `false` if aborted.
  final bool committed;

  /// Resulting data snapshot of this transaction.
  final DataSnapshot snapshot;
}

/// A special [Reference] which notifies when it's written to the database.
///
/// This reference is returned from [Reference.push] and has only one extra
/// property [done] - a [Future] which is resolved when data is written to
/// the database.
///
/// For more details see documentation for [Reference.push].
class FutureReference extends Reference {
  final Future<void> done;
  FutureReference(js.ThenableReference nativeInstance, this.done)
      : super(nativeInstance);
}

/// A `DataSnapshot` contains data from a [Database] location.
///
/// Any time you read data from the Database, you receive the data as a
/// [DataSnapshot].
class DataSnapshot<T> {
  @protected
  final js.DataSnapshot nativeInstance;

  DataSnapshot(this.nativeInstance);

  /// The key (last part of the path) of the location of this `DataSnapshot`.
  ///
  /// The last token in a [Database] location is considered its key. For example,
  /// `ada` is the key for the `/users/ada/` node. Accessing the key on any
  /// `DataSnapshot` will return the key for the location that generated it.
  /// However, accessing the key on the root URL of a `Database` will return
  /// `null`.
  String get key => nativeInstance.key;

  /// The [Reference] for the location that generated this [DataSnapshot].
  Reference get ref => new Reference(nativeInstance.ref);

  /// Gets [DataSnapshot] for the location at the specified relative [path].
  ///
  /// The relative path can either be a simple child name (for example, "ada")
  /// or a deeper, slash-separated path (for example, "ada/name/first"). If the
  /// child location has no data, an empty DataSnapshot (that is, a
  /// DataSnapshot whose value is `null`) is returned.
  DataSnapshot<S> child<S>(String path) =>
      new DataSnapshot(nativeInstance.child(path));

  /// Returns `true` if this DataSnapshot contains any data.
  ///
  /// It is slightly more efficient than using `snapshot.val() !== null`.
  bool exists() => nativeInstance.exists();

  /// Enumerates the top-level children in this `DataSnapshot`.
  ///
  /// Guarantees the children of this `DataSnapshot` are iterated in their query
  /// order.
  ///
  /// If no explicit orderBy*() method is used, results are returned ordered by
  /// key (unless priorities are used, in which case, results are returned
  /// by priority).
  bool forEach<S>(bool action(DataSnapshot<S> child)) {
    bool wrapper(js.DataSnapshot child) {
      return action(new DataSnapshot<S>(child));
    }

    return nativeInstance.forEach(allowInterop(wrapper));
  }

  bool hasChild(String path) => nativeInstance.hasChild(path);
  bool hasChildren() => nativeInstance.hasChildren();
  int numChildren() => nativeInstance.numChildren();

  T _value;

  /// Returns value stored in this data snapshot.
  T val() {
    if (_value != null) return _value;
    if (!exists()) return null; // Don't attempt to dartify empty snapshot.

    _value = dartify(nativeInstance.val());
    return _value;
  }

  // NOTE: intentionally not following JS library name – using Dart convention.
  /// Returns a JSON-serializable representation of this data snapshot.
  Object toJson() => dartify(nativeInstance.toJSON());
}
