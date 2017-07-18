// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:js' as js;

import 'package:node_interop/node_interop.dart';

import 'bindings/core.dart';
import 'bindings/database.dart';

/// Firebase Realime Database service.
class Database {
  final JsDatabase _inner;

  Database(this._inner);

  /// The Firebase app of this database.
  JsApp get app => _inner.app;

  void goOffline() {
    _inner.goOffline();
  }

  void goOnline() {
    _inner.goOnline();
  }

  Reference ref([String path]) => new Reference._(_inner.ref(path));
}

class Reference {
  final JsReference _inner;

  Reference._(this._inner);

  String get key => _inner.key;
  Reference get parent => new Reference._(_inner.parent);
  Reference get root => new Reference._(_inner.root);
  Reference child(String path) => new Reference._(_inner.child(path));
  Future<DataSnapshot> once(String eventType) {
    return jsPromiseToFuture(_inner.once(eventType))
        .then((jsSnapshot) => new DataSnapshot._(jsSnapshot));
  }

  Future<Null> set(value) {
    var jsValue;
    if (value is String ||
        value is double ||
        value is int ||
        value is bool ||
        value == null) {
      jsValue = value;
    } else {
      throw new UnsupportedError(
          'Unsupported value type: ${value.runtimeType}');
    }

    var promise = _inner.set(jsValue);
    return jsPromiseToFuture(promise);
  }
}

/// A `DataSnapshot` contains data from a [Database] location.
///
/// Any time you read data from the Database, you receive the data as a
/// `DataSnapshot`.
class DataSnapshot {
  final JsDataSnapshot _inner;

  DataSnapshot._(this._inner);

  /// The key (last part of the path) of the location of this `DataSnapshot`.
  ///
  /// The last token in a [Database] location is considered its key. For example,
  /// `ada` is the key for the `/users/ada/` node. Accessing the key on any
  /// `DataSnapshot` will return the key for the location that generated it.
  /// However, accessing the key on the root URL of a `Database` will return
  /// `null`.
  String get key => _inner.key;

  /// The [Reference] for the location that generated this `DataSnapshot`.
  Reference get ref => new Reference._(_inner.ref);

  /// Gets `DataSnapshot` for the location at the specified relative `path`.
  ///
  /// The relative path can either be a simple child name (for example, "ada") or
  /// a deeper, slash-separated path (for example, "ada/name/first"). If the child
  /// location has no data, an empty `DataSnapshot` (that is, a `DataSnapshot`
  /// whose value is `null`) is returned.
  DataSnapshot child(String path) => new DataSnapshot._(_inner.child(path));

  /// Returns true if this `DataSnapshot` contains any data.
  /// It is slightly more efficient than using snapshot.val() !== null.
  bool exists() => _inner.exists();

  /// Enumerates the top-level children in this `DataSnapshot`.
  ///
  /// Guarantees the children of this `DataSnapshot` are iterated in their query
  /// order.
  ///
  /// If no explicit orderBy*() method is used, results are returned ordered by
  /// key (unless priorities are used, in which case, results are returned
  /// by priority).
  bool forEach(bool action(DataSnapshot child)) {
    bool wrapper(JsDataSnapshot child) {
      var snapshot = new DataSnapshot._(child);
      return action(snapshot);
    }

    return _inner.forEach(js.allowInterop(wrapper));
  }

  bool hasChild(String path) => _inner.hasChild(path);
  bool hasChildren() => _inner.hasChildren();
  int numChildren() => _inner.numChildren();

  dynamic val() {
    var value = _inner.val();
    if (value is js.JsObject) {
      return jsObjectToMap(value);
    }
    return value;
  }
}
