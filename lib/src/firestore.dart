// Copyright (c) 2018, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:js';

import 'package:js/js.dart';
import 'package:meta/meta.dart';
import 'package:node_interop/js.dart';
import 'package:node_interop/node.dart';
import 'package:node_interop/stream.dart';
import 'package:node_interop/util.dart';
import 'package:quiver_hashcode/hashcode.dart';

import 'app.dart';
import 'bindings.dart' as js;

final js.FirestoreModule firestoreModule = require('@google-cloud/firestore');

js.Firestore _initWithOptions(js.AppOptions options) {
  return js.createFirestore(firestoreModule, options);
}

js.Firestore _initWithApp(App app) {
  // require('@google-cloud/firestore');
  return app.nativeInstance.firestore();
  // return _initWithOptions(app.options);
}

/// Represents a Firestore Database and is the entry point for all
/// Firestore operations.
class Firestore {
  /// JavaScript Firestore object wrapped by this instance.
  @protected
  final js.Firestore nativeInstance;

  /// Creates new Firestore client which wraps [nativeInstance].
  ///
  /// Consider using [Firestore.withOptions] or [Firestore.forApp] instead of
  /// this constructor.
  Firestore(this.nativeInstance);

  Firestore.withOptions(js.AppOptions options)
      : nativeInstance = _initWithOptions(options);
  Firestore.forApp(App app) : nativeInstance = _initWithApp(app);

  /// Gets a [CollectionReference] for the specified Firestore path.
  CollectionReference collection(String path) {
    assert(path != null);
    return new CollectionReference(nativeInstance.collection(path), this);
  }

  /// Gets a [DocumentReference] for the specified Firestore path.
  DocumentReference document(String path) {
    assert(path != null);
    return new DocumentReference(nativeInstance.doc(path), this);
  }
}

/// A CollectionReference object can be used for adding documents, getting
/// document references, and querying for documents (using the methods
/// inherited from [DocumentQuery]).
class CollectionReference extends DocumentQuery {
  CollectionReference(
      js.CollectionReference nativeInstance, Firestore firestore)
      : super(nativeInstance, firestore);

  @override
  @protected
  js.CollectionReference get nativeInstance => super.nativeInstance;

  /// For subcollections, parent returns the containing DocumentReference.
  ///
  /// For root collections, null is returned.
  DocumentReference get parent {
    return (nativeInstance.parent != null)
        ? new DocumentReference(nativeInstance.parent, firestore)
        : null;
  }

  /// Returns a `DocumentReference` with the provided path.
  ///
  /// If no [path] is provided, an auto-generated ID is used.
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  DocumentReference document([String path]) =>
      new DocumentReference(nativeInstance.doc(path), firestore);

  /// Returns a `DocumentReference` with an auto-generated ID, after
  /// populating it with provided [data].
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  Future<DocumentReference> add(Map<String, dynamic> data) {
    return promiseToFuture(nativeInstance.add(jsify(data)))
        .then((jsRef) => new DocumentReference(jsRef, firestore));
  }
}

/// A [DocumentReference] refers to a document location in a Firestore database
/// and can be used to write, read, or listen to the location.
///
/// The document at the referenced location may or may not exist.
/// A [DocumentReference] can also be used to create a [CollectionReference]
/// to a subcollection.
class DocumentReference {
  DocumentReference(this.nativeInstance, this.firestore);

  @protected
  final js.DocumentReference nativeInstance;
  final Firestore firestore;

  /// Slash-delimited path representing the database location of this query.
  String get path => nativeInstance.path;

  /// This document's given or generated ID in the collection.
  String get documentID => nativeInstance.id;

  /// Writes to the document referred to by this [DocumentReference]. If the
  /// document does not yet exist, it will be created. If you pass [SetOptions],
  /// the provided data will be merged into an existing document.
  Future setData(Map<String, dynamic> data, [js.SetOptions options]) {
    // Even though bindings declare special DocumentData type, in reality
    // it's a regular POJO.
    final docData = jsify(data);
    if (options != null) {
      return promiseToFuture(nativeInstance.set(docData, options));
    }
    return promiseToFuture(nativeInstance.set(docData));
  }

  /// Updates fields in the document referred to by this [DocumentReference].
  ///
  /// If no document exists yet, the update will fail.
  Future updateData(Map<String, dynamic> data) {
    // Even though bindings declare special DocumentData type, in reality
    // it's a regular POJO.
    final docData = jsify(data);
    return promiseToFuture(nativeInstance.update(docData));
  }

  /// Reads the document referenced by this [DocumentReference].
  ///
  /// If no document exists, the read will return null.
  Future<DocumentSnapshot> get() {
    return promiseToFuture(nativeInstance.get())
        .then((jsSnapshot) => new DocumentSnapshot(jsSnapshot, firestore));
  }

  /// Deletes the document referred to by this [DocumentReference].
  Future delete() => promiseToFuture(nativeInstance.delete());

  /// Returns the reference of a collection contained inside of this
  /// document.
  CollectionReference collection(String path) =>
      new CollectionReference(nativeInstance.collection(path), firestore);

  /// Notifies of documents at this location.
  Stream<DocumentSnapshot> get snapshots {
    Function cancelCallback;
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    StreamController<DocumentSnapshot> controller; // ignore: close_sinks

    void _onNextSnapshot(js.DocumentSnapshot jsSnapshot) {
      controller.add(new DocumentSnapshot(jsSnapshot, firestore));
    }

    controller = new StreamController<DocumentSnapshot>.broadcast(
      onListen: () {
        cancelCallback =
            nativeInstance.onSnapshot(allowInterop(_onNextSnapshot));
      },
      onCancel: () {
        cancelCallback();
      },
    );
    return controller.stream;
  }
}

/// An enumeration of document change types.
enum DocumentChangeType {
  /// Indicates a new document was added to the set of documents matching the
  /// query.
  added,

  /// Indicates a document within the query was modified.
  modified,

  /// Indicates a document within the query was removed (either deleted or no
  /// longer matches the query.
  removed,
}

/// A DocumentChange represents a change to the documents matching a query.
///
/// It contains the document affected and the type of change that occurred
/// (added, modified, or removed).
class DocumentChange {
  DocumentChange(this.nativeInstance, this.firestore);

  @protected
  final js.DocumentChange nativeInstance;
  final Firestore firestore;

  /// The type of change that occurred (added, modified, or removed).
  DocumentChangeType get type {
    if (_type != null) return _type;
    _type = DocumentChangeType.values.firstWhere((value) {
      return value.toString().endsWith(nativeInstance.type);
    });
    return _type;
  }

  DocumentChangeType _type;

  /// The index of the changed document in the result set immediately prior to
  /// this [DocumentChange] (i.e. supposing that all prior DocumentChange objects
  /// have been applied).
  ///
  /// -1 for [DocumentChangeType.added] events.
  int get oldIndex => nativeInstance.oldIndex.toInt();

  /// The index of the changed document in the result set immediately after this
  /// DocumentChange (i.e. supposing that all prior [DocumentChange] objects
  /// and the current [DocumentChange] object have been applied).
  ///
  /// -1 for [DocumentChangeType.removed] events.
  int get newIndex => nativeInstance.newIndex.toInt();

  /// The document affected by this change.
  DocumentSnapshot get document =>
      _document ??= new DocumentSnapshot(nativeInstance.doc, firestore);
  DocumentSnapshot _document;
}

class DocumentSnapshot {
  DocumentSnapshot(this.nativeInstance, this.firestore);

  @protected
  final js.DocumentSnapshot nativeInstance;
  final Firestore firestore;

  /// The reference that produced this snapshot
  DocumentReference get reference =>
      _reference ??= new DocumentReference(nativeInstance.ref, firestore);
  DocumentReference _reference;

  /// Contains all the data of this snapshot
  DocumentData get data => _data ??= new DocumentData(nativeInstance.data());
  DocumentData _data;

  /// Returns `true` if the document exists.
  bool get exists => nativeInstance.exists;

  /// Returns the ID of the snapshot's document
  String get documentID => nativeInstance.id;

  DateTime get createTime => nativeInstance.createTime != null
      ? DateTime.parse(nativeInstance.createTime)
      : null;

  DateTime get updateTime => DateTime.parse(nativeInstance.updateTime);
}

class DocumentData {
  DocumentData(this.nativeInstance);

  @protected
  final js.DocumentData nativeInstance;

  int get length => objectKeys(nativeInstance).length;

  String getString(String key) => (getProperty(nativeInstance, key) as String);
  void setString(String key, String value) {
    setProperty(nativeInstance, key, value);
  }

  int getInt(String key) => (getProperty(nativeInstance, key) as int);
  void setInt(String key, int value) {
    setProperty(nativeInstance, key, value);
  }

  double getDouble(String key) => (getProperty(nativeInstance, key) as double);
  void setDouble(String key, double value) {
    setProperty(nativeInstance, key, value);
  }

  bool getBool(String key) => (getProperty(nativeInstance, key) as bool);
  void setBool(String key, bool value) {
    setProperty(nativeInstance, key, value);
  }

  DateTime getDateTime(String key) {
    Date date = getProperty(nativeInstance, key);
    if (date == null) return null;
    return new DateTime.fromMillisecondsSinceEpoch(date.getTime());
  }

  void setDateTime(String key, DateTime value) {
    assert(key != null);
    final data =
        (value != null) ? new Date(value.millisecondsSinceEpoch) : null;
    setProperty(nativeInstance, key, data);
  }

  GeoPoint getGeoPoint(String key) {
    js.GeoPoint value = getProperty(nativeInstance, key);
    if (value == null) return null;
    return new GeoPoint(value.latitude.toDouble(), value.longitude.toDouble());
  }

  void setGeoPoint(String key, GeoPoint value) {
    assert(key != null);
    final data = (value != null)
        ? new js.GeoPoint(latitude: value.latitude, longitude: value.longitude)
        : null;
    setProperty(nativeInstance, key, data);
  }

  List<T> getList<T>(String key) {
    final data = getProperty(nativeInstance, key);
    if (data == null) return null;
    // TODO: this would fail if list contains complex types like GeoPoint.
    return dartify(data) as List<T>;
  }

  void setList<T>(String key, List<T> value) {
    assert(key != null);
    // TODO: this would fail if list contains complex types like GeoPoint.
    final data = (value != null) ? jsify(value) : null;
    setProperty(nativeInstance, key, data);
  }

  DocumentReference getReference(String key) {
    js.DocumentReference ref = getProperty(nativeInstance, key);
    if (ref == null) return null;
    assert(objectKeys(ref).contains('_referencePath'));
    js.Firestore firestore = getProperty(ref, '_firestore');
    return new DocumentReference(ref, new Firestore(firestore));
  }

  void setReference(String key, DocumentReference value) {
    assert(key != null);
    final data = (value != null) ? value.nativeInstance : null;
    setProperty(nativeInstance, key, data);
  }
}

class GeoPoint {
  final double latitude;
  final double longitude;

  GeoPoint(this.latitude, this.longitude);

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! GeoPoint) return false;
    GeoPoint point = other;
    return latitude == point.latitude && longitude == point.longitude;
  }

  @override
  int get hashCode => hash2(latitude, longitude);
}

/// A QuerySnapshot contains zero or more DocumentSnapshot objects.
class QuerySnapshot {
  QuerySnapshot(this.nativeInstance, this.firestore);

  @protected
  final js.QuerySnapshot nativeInstance;
  final Firestore firestore;

  /// Gets a list of all the documents included in this snapshot
  List<DocumentSnapshot> get documents => _documents ??= nativeInstance.docs
      .map((jsDoc) => new DocumentSnapshot(jsDoc, firestore))
      .toList(growable: false);
  List<DocumentSnapshot> _documents;

  /// An array of the documents that changed since the last snapshot. If this
  /// is the first snapshot, all documents will be in the list as Added changes.
  List<DocumentChange> get documentChanges =>
      _changes ??= nativeInstance.docChanges
          .map((jsChange) => new DocumentChange(jsChange, firestore))
          .toList(growable: false);
  List<DocumentChange> _changes;
}

/// Represents a query over the data at a particular location.
class DocumentQuery {
  DocumentQuery(this.nativeInstance, this.firestore);

  @protected
  final js.DocumentQuery nativeInstance;
  final Firestore firestore;

  /// Notifies of query results at this location
  Stream<QuerySnapshot> get snapshots {
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    StreamController<QuerySnapshot> controller; // ignore: close_sinks

    void onSnapshot(js.QuerySnapshot snapshot) {
      controller.add(new QuerySnapshot(snapshot, firestore));
    }

    void onError(error) {
      controller.addError(error);
    }

    Readable stream;

    controller = new StreamController<QuerySnapshot>.broadcast(
      onListen: () {
        stream = nativeInstance.stream();
        stream.on('data', allowInterop(onSnapshot));
        stream.on('error', allowInterop(onError));
      },
      onCancel: () {
        stream.removeAllListeners('data');
        stream.removeAllListeners('error');
      },
    );
    return controller.stream;
  }

  /// Creates and returns a new [DocumentQuery] with additional filter on specified
  /// [field].
  ///
  /// Only documents satisfying provided condition are included in the result
  /// set.
  DocumentQuery where(
    String field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    bool isNull,
  }) {
    js.DocumentQuery query = nativeInstance;

    void addCondition(String field, String opStr, dynamic value) {
      query = query.where(field, opStr, value);
    }

    if (isEqualTo != null) addCondition(field, '==', isEqualTo);
    if (isLessThan != null) addCondition(field, '<', isLessThan);
    if (isLessThanOrEqualTo != null)
      addCondition(field, '<=', isLessThanOrEqualTo);
    if (isGreaterThan != null) addCondition(field, '>', isGreaterThan);
    if (isGreaterThanOrEqualTo != null)
      addCondition(field, '>=', isGreaterThanOrEqualTo);
    if (isNull != null) {
      assert(
          isNull,
          'isNull can only be set to true. '
          'Use isEqualTo to filter on non-null values.');
      addCondition(field, '==', null);
    }

    return new DocumentQuery(query, firestore);
  }

  /// Creates and returns a new [DocumentQuery] that's additionally sorted by the specified
  /// [field].
  DocumentQuery orderBy(String field, {bool descending: false}) {
    String direction = descending ? 'desc' : 'asc';
    return new DocumentQuery(
        nativeInstance.orderBy(field, direction), firestore);
  }

  /// Takes a list of [values], creates and returns a new [DocumentQuery] that starts after
  /// the provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [startAt].
  DocumentQuery startAfter(List<dynamic> values) {
    final jsValues = jsify(values);
    return new DocumentQuery(nativeInstance.startAfter(jsValues), firestore);
  }

  /// Takes a list of [values], creates and returns a new [DocumentQuery] that starts at
  /// the provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [startAfter].
  DocumentQuery startAt(List<dynamic> values) {
    final jsValues = jsify(values);
    return new DocumentQuery(nativeInstance.startAt(jsValues), firestore);
  }

  /// Takes a list of [values], creates and returns a new [DocumentQuery] that ends at the
  /// provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [endBefore].
  DocumentQuery endAt(List<dynamic> values) {
    assert(values != null);
    final jsValues = jsify(values);
    return new DocumentQuery(nativeInstance.endAt(jsValues), firestore);
  }

  /// Takes a list of [values], creates and returns a new [DocumentQuery] that ends before
  /// the provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [endAt].
  DocumentQuery endBefore(List<dynamic> values) {
    assert(values != null);
    final jsValues = jsify(values);
    return new DocumentQuery(nativeInstance.endBefore(jsValues), firestore);
  }

  /// Creates and returns a new Query that's additionally limited to only return up
  /// to the specified number of documents.
  DocumentQuery limit(int length) {
    assert(length != null);
    return new DocumentQuery(nativeInstance.limit(length), firestore);
  }
}
