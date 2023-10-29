// Copyright (c) 2018, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:js';
import 'dart:typed_data';

import 'package:js/js.dart';
import 'package:meta/meta.dart';
import 'package:node_interop/js.dart' as node;
import 'package:node_interop/node.dart' as node;
import 'package:node_interop/util.dart' as node;
import 'package:quiver/core.dart';

import 'bindings.dart' as js;

@Deprecated('This function will be hidden from public API in future versions.')
js.GeoPoint createGeoPoint(num latitude, num longitude) =>
    _createJsGeoPoint(latitude, longitude);

js.GeoPoint _createJsGeoPoint(num latitude, num longitude) {
  final proto = js.GeoPointProto(latitude: latitude, longitude: longitude);
  return js.admin!.firestore.GeoPoint.fromProto(proto);
}

js.Timestamp? _createJsTimestamp(Timestamp ts) {
  return node.callConstructor(js.admin!.firestore.Timestamp,
          node.jsify([ts.seconds, ts.nanoseconds]) as List<Object?>?)
      as js.Timestamp?;
}

@Deprecated('This function will be hidden from public API in future versions.')
js.FieldPath? createFieldPath(List<String> fieldNames) {
  return node.callConstructor(js.admin!.firestore.FieldPath,
      node.jsify(fieldNames) as List<Object?>?) as js.FieldPath;
}

/// Returns a special sentinel [FieldPath] to refer to the ID of a document.
/// It can be used in queries to sort or filter by the document ID.
@Deprecated('Use "Firestore.documentId" instead.')
js.FieldPath documentId() {
  final proto = js.admin!.firestore.FieldPath;
  return proto.documentId();
}

/// Represents a Firestore Database and is the entry point for all
/// Firestore operations.
class Firestore {
  /// Sentinel field values that can be used when writing document fields with
  /// `set` or `update`.
  static final FieldValues fieldValues = FieldValues._();

  /// Returns a special sentinel [FieldPath] to refer to the ID of a document.
  /// It can be used in queries to sort or filter by the document ID.
  static js.FieldPath documentId() {
    final proto = js.admin!.firestore.FieldPath;
    return proto.documentId();
  }

  /// JavaScript Firestore object wrapped by this instance.
  @protected
  final js.Firestore nativeInstance;

  /// Creates new Firestore Database client which wraps [nativeInstance].
  Firestore(this.nativeInstance);

  /// Specifies custom settings to be used to configure the `Firestore`
  /// instance.
  ///
  /// Can only be invoked once and before any other [Firestore] method.
  void settings(js.FirestoreSettings settings) {
    nativeInstance.settings(settings);
  }

  /// Gets a [CollectionReference] for the specified Firestore path.
  CollectionReference collection(String path) {
    return CollectionReference(nativeInstance.collection(path), this);
  }

  /// Creates and returns a new Query that includes all documents in the
  /// database that are contained in a collection or subcollection with the
  /// given [collectionId].
  ///
  /// [collectionId] identifies the collections to query over. Every collection
  /// or subcollection with this ID as the last segment of its path will be
  /// included. Cannot contain a slash.
  DocumentQuery collectionGroup(String collectionId) {
    return DocumentQuery(nativeInstance.collectionGroup(collectionId), this);
  }

  /// Gets a [DocumentReference] for the specified Firestore path.
  DocumentReference document(String path) {
    return DocumentReference(nativeInstance.doc(path), this);
  }

  /// Executes the given [updateFunction] and commits the changes applied within
  /// the transaction.
  ///
  /// You can use the transaction object passed to [updateFunction] to read and
  /// modify Firestore documents under lock. Transactions are committed once
  /// [updateFunction] resolves and attempted up to five times on failure.
  ///
  /// Returns the same `Future` returned by [updateFunction] if transaction
  /// completed successfully of was explicitly aborted by returning a Future
  /// with an error. If [updateFunction] throws then returned Future completes
  /// with the same error.
  Future<T> runTransaction<T>(
      Future<T> Function(Transaction transaction) updateFunction) {
    node.Promise jsUpdateFunction(js.Transaction transaction) {
      return node.futureToPromise(updateFunction(Transaction(transaction)));
    }

    return node.promiseToFuture<T>(
        nativeInstance.runTransaction(allowInterop(jsUpdateFunction)));
  }

  /// Fetches the root collections that are associated with this Firestore
  /// database.
  Future<List<CollectionReference>> listCollections() async =>
      (await node.promiseToFuture<List>(nativeInstance.listCollections()))
          .map((nativeCollectionReference) => CollectionReference(
              nativeCollectionReference as js.CollectionReference, this))
          .toList(growable: false);

  /// Creates a write batch, used for performing multiple writes as a single
  /// atomic operation.
  WriteBatch batch() => WriteBatch(nativeInstance.batch());

  /// Retrieves multiple documents from Firestore.
  Future<List<DocumentSnapshot>> getAll(List<DocumentReference> refs) async {
    final nativeRefs = refs
        .map((DocumentReference ref) => ref.nativeInstance)
        .toList(growable: false);
    final promise =
        node.callMethod(nativeInstance, 'getAll', nativeRefs) as node.Promise;
    final result = await node.promiseToFuture<List>(promise);
    return result
        .map((nativeSnapshot) =>
            DocumentSnapshot(nativeSnapshot as js.DocumentSnapshot, this))
        .toList(growable: false);
  }
}

/// A CollectionReference object can be used for adding documents, getting
/// document references, and querying for documents (using the methods
/// inherited from [DocumentQuery]).
class CollectionReference extends DocumentQuery {
  CollectionReference(
      js.CollectionReference super.nativeInstance, super.firestore);

  @override
  @protected
  js.CollectionReference? get nativeInstance =>
      super.nativeInstance as js.CollectionReference?;

  /// For subcollections, parent returns the containing DocumentReference.
  ///
  /// For root collections, null is returned.
  DocumentReference? get parent {
    return (nativeInstance!.parent != null)
        ? DocumentReference(nativeInstance!.parent!, firestore)
        : null;
  }

  /// Returns a `DocumentReference` with the provided path.
  ///
  /// If no [path] is provided, an auto-generated ID is used.
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  DocumentReference document([String? path]) {
    final docRef =
        (path == null) ? nativeInstance!.doc() : nativeInstance!.doc(path);
    return DocumentReference(docRef, firestore);
  }

  /// Returns a `DocumentReference` with an auto-generated ID, after
  /// populating it with provided [data].
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  Future<DocumentReference> add(DocumentData data) {
    return node
        .promiseToFuture<js.DocumentReference>(
            nativeInstance!.add(data.nativeInstance))
        .then((jsRef) => DocumentReference(jsRef, firestore));
  }

  /// The last path element of the referenced collection.
  String get id => nativeInstance!.id;

  /// A string representing the path of the referenced collection (relative to
  /// the root of the database).
  String get path => nativeInstance!.path;
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

  CollectionReference get parent {
    return CollectionReference(nativeInstance.parent, firestore);
  }

  /// Writes to the document referred to by this [DocumentReference]. If the
  /// document does not yet exist, it will be created. If you pass [SetOptions],
  /// the provided data will be merged into an existing document.
  Future<void> setData(DocumentData data, [js.SetOptions? options]) {
    final docData = data.nativeInstance;
    if (options != null) {
      return node.promiseToFuture(nativeInstance.set(docData, options));
    }
    return node.promiseToFuture(nativeInstance.set(docData));
  }

  /// Updates fields in the document referred to by this [DocumentReference].
  ///
  /// If no document exists yet, the update will fail.
  Future<void> updateData(UpdateData data) {
    final docData = data.nativeInstance;
    return node
        .promiseToFuture(nativeInstance.update(docData as js.UpdateData));
  }

  /// Reads the document referenced by this [DocumentReference].
  ///
  /// If no document exists, the read will return null.
  Future<DocumentSnapshot> get() {
    return node.promiseToFuture<Object?>(nativeInstance.get()).then(
        (jsSnapshot) =>
            DocumentSnapshot(jsSnapshot as js.DocumentSnapshot, firestore));
  }

  /// Deletes the document referred to by this [DocumentReference].
  Future<void> delete() => node.promiseToFuture(nativeInstance.delete());

  /// Returns the reference of a collection contained inside of this
  /// document.
  CollectionReference collection(String path) =>
      CollectionReference(nativeInstance.collection(path), firestore);

  /// Notifies of documents at this location.
  Stream<DocumentSnapshot> get snapshots {
    late Function cancelCallback;
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    late StreamController<DocumentSnapshot> controller; // ignore: close_sinks

    void onNextSnapshot(js.DocumentSnapshot jsSnapshot) {
      controller.add(DocumentSnapshot(jsSnapshot, firestore));
    }

    controller = StreamController<DocumentSnapshot>.broadcast(
      onListen: () {
        cancelCallback =
            nativeInstance.onSnapshot(allowInterop(onNextSnapshot));
      },
      onCancel: () {
        (cancelCallback as dynamic Function())();
      },
    );
    return controller.stream;
  }

  /// Fetches the subcollections that are direct children of this document.
  Future<List<CollectionReference>> listCollections() async =>
      (await node.promiseToFuture<List>(nativeInstance.listCollections()))
          .map((nativeCollectionReference) => CollectionReference(
              nativeCollectionReference as js.CollectionReference, firestore))
          .toList(growable: false);
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
  ///
  /// Can be `null` if this document change was returned from [DocumentQuery.get].
  DocumentChangeType? get type {
    if (_type != null) return _type;
    if (nativeInstance.type == 'added') {
      _type = DocumentChangeType.added;
    } else if (nativeInstance.type == 'modified') {
      _type = DocumentChangeType.modified;
    } else if (nativeInstance.type == 'removed') {
      _type = DocumentChangeType.removed;
    }
    return _type;
  }

  DocumentChangeType? _type;

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
      _document ??= DocumentSnapshot(nativeInstance.doc, firestore);
  DocumentSnapshot? _document;
}

class DocumentSnapshot {
  DocumentSnapshot(this.nativeInstance, this.firestore);

  @protected
  final js.DocumentSnapshot nativeInstance;
  final Firestore firestore;

  /// The reference that produced this snapshot
  DocumentReference get reference =>
      _reference ??= DocumentReference(nativeInstance.ref, firestore);
  DocumentReference? _reference;

  /// Contains all the data of this snapshot
  DocumentData get data => _data ??= DocumentData(nativeInstance.data());
  DocumentData? _data;

  /// Returns `true` if the document exists.
  bool get exists => nativeInstance.exists;

  /// Returns the ID of the snapshot's document
  String get documentID => nativeInstance.id;

  /// The time the document was created. Not set for documents that don't
  /// exist.
  Timestamp? get createTime {
    final ts = nativeInstance.createTime;
    if (ts == null) return null;
    return Timestamp(ts.seconds, ts.nanoseconds);
  }

  /// The time the document was last updated (at the time the snapshot was
  /// generated). Not set for documents that don't exist.
  ///
  /// Note that this value includes nanoseconds and can not be represented
  /// by a [DateTime] object with expected accuracy when used in [Transaction].
  Timestamp? get updateTime {
    final ts = nativeInstance.updateTime;
    if (ts == null) return null;
    return Timestamp(ts.seconds, ts.nanoseconds);
  }
}

class _FirestoreData {
  _FirestoreData([Object? nativeInstance])
      : nativeInstance =
            (nativeInstance ?? node.newObject()) as js.DocumentData;
  @protected
  final js.DocumentData nativeInstance;

  /// Length of this document.
  int get length => node.objectKeys(nativeInstance).length;

  bool get isEmpty => length == 0;

  bool get isNotEmpty => !isEmpty;

  void _setField(String key, dynamic value) {
    if (value == null) {
      node.setProperty(nativeInstance, key, null);
    } else if (value is String) {
      setString(key, value);
    } else if (value is int) {
      setInt(key, value);
    } else if (value is double) {
      setDouble(key, value);
    } else if (value is bool) {
      setBool(key, value);
    } else if (value is DateTime) {
      // ignore: deprecated_member_use, deprecated_member_use_from_same_package
      setDateTime(key, value);
    } else if (value is GeoPoint) {
      setGeoPoint(key, value);
    } else if (value is Blob) {
      setBlob(key, value);
    } else if (value is DocumentReference) {
      setReference(key, value);
    } else if (value is List) {
      setList(key, value);
    } else if (value is Timestamp) {
      setTimestamp(key, value);
    } else if (value is FieldValue) {
      setFieldValue(key, value);
    } else if (value is Map) {
      setNestedData(key, DocumentData.fromMap(value.cast<String, dynamic>()));
    } else {
      throw ArgumentError.value(
          value, key, 'Unsupported value type for Firestore.');
    }
  }

  String? getString(String key) =>
      (node.getProperty(nativeInstance, key) as String?);

  void setString(String key, String value) {
    node.setProperty(nativeInstance, key, value);
  }

  int? getInt(String key) => (node.getProperty(nativeInstance, key) as int?);

  void setInt(String key, int? value) {
    node.setProperty(nativeInstance, key, value);
  }

  double? getDouble(String key) =>
      (node.getProperty(nativeInstance, key) as double?);

  void setDouble(String key, double value) {
    node.setProperty(nativeInstance, key, value);
  }

  bool? getBool(String key) => (node.getProperty(nativeInstance, key) as bool?);

  void setBool(String key, bool value) {
    node.setProperty(nativeInstance, key, value);
  }

  /// Returns true if this data contains an entry with the given [key].
  bool has(String key) => node.hasProperty(nativeInstance, key);

  @Deprecated('Migrate to using Firestore Timestamps and "getTimestamp()".')
  DateTime? getDateTime(String key) {
    final value = node.getProperty(nativeInstance, key) as node.Date?;
    if (value == null) return null;
    assert(_isDate(value), 'Tried to get Date and got $value');
    return DateTime.fromMillisecondsSinceEpoch(value.getTime());
  }

  Timestamp? getTimestamp(String key) {
    var ts = node.getProperty(nativeInstance, key) as js.Timestamp?;
    if (ts == null) return null;
    assert(_isTimestamp(ts), 'Tried to get Timestamp and got $ts.');
    return Timestamp(ts.seconds, ts.nanoseconds);
  }

  @Deprecated('Migrate to using Firestore Timestamps and "setTimestamp()".')
  void setDateTime(String key, DateTime value) {
    final data = node.Date(value.millisecondsSinceEpoch);
    node.setProperty(nativeInstance, key, data);
  }

  void setTimestamp(String key, Timestamp value) {
    final ts = _createJsTimestamp(value);
    node.setProperty(nativeInstance, key, ts);
  }

  GeoPoint? getGeoPoint(String key) {
    var value = node.getProperty(nativeInstance, key) as js.GeoPoint?;
    if (value == null) return null;
    assert(_isGeoPoint(value),
        'Invalid value provided to $runtimeType.getGeoPoint().');
    return GeoPoint(value.latitude.toDouble(), value.longitude.toDouble());
  }

  Blob? getBlob(String key) {
    var value = node.getProperty(nativeInstance, key) as Object?;
    if (value == null) return null;
    assert(_isBlob(value), 'Invalid value provided to $runtimeType.getBlob().');
    return Blob(value as List<int>);
  }

  void setGeoPoint(String key, GeoPoint value) {
    final data = _createJsGeoPoint(value.latitude, value.longitude);
    node.setProperty(nativeInstance, key, data);
  }

  void setBlob(String key, Blob value) {
    final data = value.data;
    node.setProperty(nativeInstance, key, data);
  }

  void setFieldValue(String key, FieldValue value) {
    node.setProperty(nativeInstance, key, value._jsify());
  }

  void setNestedData(String key, DocumentData value) {
    node.setProperty(nativeInstance, key, value.nativeInstance);
  }

  static bool _isPrimitive(Object? value) =>
      value == null ||
      value is int ||
      value is double ||
      value is String ||
      value is bool;

  List? getList(String key) {
    final data = node.getProperty<Object?>(nativeInstance, key);
    if (data == null) return null;
    if (data is! List) {
      throw StateError('Expected list but got ${data.runtimeType}.');
    }
    final result = <Object?>[];
    for (var item in data) {
      item = _dartify(item);
      result.add(item);
    }
    return result;
  }

  void setList(String key, List value) {
    // The contents remains is js
    final data = _jsifyList(value);

    node.setProperty(nativeInstance, key, data);
  }

  DocumentReference? getReference(String key) {
    var ref = node.getProperty(nativeInstance, key) as js.DocumentReference?;
    if (ref == null) return null;
    assert(_isReference(ref),
        'Invalid value provided to $runtimeType.getReference().');

    var firestore = ref.firestore;
    return DocumentReference(ref, Firestore(firestore));
  }

  void setReference(String key, DocumentReference value) {
    final data = value.nativeInstance;
    node.setProperty(nativeInstance, key, data);
  }

  bool _isTimestamp(Object value) =>
      node.hasProperty(value, '_seconds') &&
      node.hasProperty(value, '_nanoseconds');

  // Workarounds for dart2js as `value is Type` doesn't work as expected.
  bool _isDate(Object value) =>
      node.hasProperty(value, 'toDateString') &&
      node.hasProperty(value, 'getTime') &&
      node.getProperty<Object?>(value, 'getTime') is Function;

  bool _isGeoPoint(Object value) =>
      node.hasProperty(value, '_latitude') &&
      node.hasProperty(value, '_longitude');

  bool _isBlob(Object value) {
    if (value is Uint8List) {
      return true;
    } else {
      var proto = node.getProperty(value, '__proto__') as Object?;
      if (proto != null) {
        return node.getProperty<Object?>(proto, 'writeUInt8') is Function &&
            node.getProperty<Object?>(proto, 'readUInt8') is Function;
      }
      return false;
    }
  }

  bool _isReference(Object value) =>
      node.hasProperty(value, 'firestore') &&
      node.hasProperty(value, 'id') &&
      node.hasProperty(value, 'onSnapshot') &&
      node.getProperty<Object?>(value, 'onSnapshot') is Function;

  // TODO: figure out how to handle array* field values. For now ignored as they
  // don't need js to dart conversion
  bool _isFieldValue(Object? value) {
    if (value == js.admin!.firestore.FieldValue.delete() ||
        value == js.admin!.firestore.FieldValue.serverTimestamp()) {
      return true;
    }
    return false;
  }

  /// Supports nested List and maps.
  static dynamic _jsify(Object? item) {
    if (_isPrimitive(item)) {
      return item;
    } else if (item is GeoPoint) {
      var point = item;
      return _createJsGeoPoint(point.latitude, point.longitude);
    } else if (item is DocumentReference) {
      var ref = item;
      return ref.nativeInstance;
    } else if (item is Blob) {
      var blob = item;
      return blob.data;
    } else if (item is DateTime) {
      var date = item;
      return node.Date(date.millisecondsSinceEpoch);
    } else if (item is Timestamp) {
      return _createJsTimestamp(item);
    } else if (item is FieldValue) {
      return item._jsify();
    } else if (item is List) {
      return _jsifyList(item);
    } else if (item is Map) {
      return DocumentData.fromMap(item.cast<String, dynamic>()).nativeInstance;
    } else {
      throw UnsupportedError(
          'Value of type ${item.runtimeType} is not supported by Firestore.');
    }
  }

  dynamic _dartify(Object? item) {
    /// This is a best-effort implementation which attempts to convert
    /// built-in Firestore data types into Dart objects.
    ///
    /// We check types starting with higher level of confidence:
    /// 1. Primitive types (int, bool, String, double, null)
    /// 2. Data types with properties of type [Function]: DateTime, DocumentReference
    /// 3. GeoPoint
    /// 4. Blob
    /// 5. Timestamp
    /// 6. Date
    /// 7. Field value
    /// 8. Lists
    /// 7. Nested arbitrary maps.
    ///
    /// The assumption is that Firestore does not support storing [Function]
    /// values so if a native object contains a known function property
    /// (`Date.getTime` or `DocumentReference.onSnapshot`) it should be safe to
    /// treat it as such type.
    ///
    /// The only possible mismatch here would be treating an arbitrary nested
    /// map as a GeoPoint because we can only check presence of `latitude` and
    /// `longitude`. The [_isGeoPoint] method relies additionally on the output
    /// of `GeoPoint.toString()` method which must contain "GeoPoint".
    /// See: https://github.com/googleapis/nodejs-firestore/blob/35c1af0d0afc660b467d411f5de39792f8330be2/src/document.js#L129
    if (_isPrimitive(item)) {
      return item;
    } else if (_isGeoPoint(item!)) {
      var point = item as js.GeoPoint;
      return GeoPoint(point.latitude.toDouble(), point.longitude.toDouble());
    } else if (_isReference(item)) {
      var ref = item as js.DocumentReference;
      var firestore = ref.firestore;
      return DocumentReference(ref, Firestore(firestore));
    } else if (_isBlob(item)) {
      return Blob(item as List<int>);
    } else if (_isTimestamp(item)) {
      var ts = item as js.Timestamp;
      return Timestamp(ts.seconds, ts.nanoseconds);
    } else if (_isDate(item)) {
      var date = item as node.Date;
      return DateTime.fromMillisecondsSinceEpoch(date.getTime());
    } else if (_isFieldValue(item)) {
      return FieldValue._fromJs(item);
    } else if (item is List) {
      return _dartifyList(item);
    } else {
      // Handle like any object
      return _dartifyObject(item);
    }
  }

  static List _jsifyList(List list) {
    var data = <Object?>[];
    for (dynamic item in list) {
      if (item is List) {
        // Otherwise this crashes in firestore
        // we cannot have list of lists such as [[1]]
        throw ArgumentError('A list item cannot be a List');
      }
      data.add(_jsify(item));
    }
    return data;
  }

  List _dartifyList(List list) {
    return list.map(_dartify).toList();
  }

  Map<String, dynamic> _dartifyObject(Object object) {
    return DocumentData(object as js.DocumentData).toMap();
  }

  @override
  String toString() => '$runtimeType';
}

/// Data stored in a Firestore Document.
///
/// This class represents full data snapshot of a document as a tree.
/// This class provides typed methods to get and set field values in a document.
///
/// Use [setNestedData] and [getNestedData] to access data in nested fields.
///
/// See also:
/// - [UpdateData] which is used to update a part of a document and follows
///   different pattern for handling nested fields.
class DocumentData extends _FirestoreData {
  DocumentData([js.DocumentData? super.nativeInstance]);

  factory DocumentData.fromMap(Map<String, dynamic> data) {
    final doc = DocumentData();
    data.forEach(doc._setField);
    return doc;
  }

  DocumentData? getNestedData(String key) {
    final data = node.getProperty(nativeInstance, key) as js.DocumentData?;
    if (data == null) return null;
    return DocumentData(data);
  }

  /// List of keys in this document data.
  List<String> get keys => node.objectKeys(nativeInstance);

  /// Converts this document data into a [Map].
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    for (var key in keys) {
      map[key] = _dartify(node.getProperty(nativeInstance, key));
    }
    return map;
  }
}

/// Represents data to update in a Firestore document.
///
/// Main difference of this class from [DocumentData] is in how nested fields
/// are handled.
///
/// [DocumentData] always represents full snapshot of a document as a tree.
/// [UpdateData] represents only a part of the document which must be updated,
/// and nested fields use dot-separated keys. For instance,
///
///     // Using DocumentData with "profile" field which itself contains
///     // "name" field:
///     DocumentData profile = new DocumentData();
///     profile.setString("name", "John");
///     DocumentData doc = new DocumentData();
///     doc.setNestedData("profile", profile);
///
///     // Using UpdateData to update profile name:
///     UpdateData data = new UpdateData();
///     data.setString("profile.name", "John");
class UpdateData extends _FirestoreData {
  UpdateData([js.UpdateData? super.nativeInstance]);

  factory UpdateData.fromMap(Map<String, dynamic> data) {
    final doc = UpdateData();
    data.forEach(doc._setField);
    return doc;
  }
}

/// Represents Firestore timestamp object.
class Timestamp {
  final int seconds;
  final int nanoseconds;

  Timestamp(this.seconds, this.nanoseconds);

  factory Timestamp.fromDateTime(DateTime dateTime) {
    final seconds = dateTime.millisecondsSinceEpoch ~/ 1000;
    final nanoseconds = (dateTime.microsecondsSinceEpoch % 1000000) * 1000;
    return Timestamp(seconds, nanoseconds);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Timestamp) return false;
    var typedOther = other;
    return seconds == typedOther.seconds &&
        nanoseconds == typedOther.nanoseconds;
  }

  @override
  int get hashCode => hash2(seconds, nanoseconds);

  int get millisecondsSinceEpoch => (microsecondsSinceEpoch / 1000).floor();

  int get microsecondsSinceEpoch {
    return (seconds * 1000000 + nanoseconds / 1000).floor();
  }

  DateTime toDateTime() {
    return DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch);
  }
}

/// Represents Firestore geo point object.
class GeoPoint {
  final double latitude;
  final double longitude;

  GeoPoint(this.latitude, this.longitude);

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! GeoPoint) return false;
    var point = other;
    return latitude == point.latitude && longitude == point.longitude;
  }

  @override
  int get hashCode => hash2(latitude, longitude);

  @override
  String toString() {
    return 'GeoPoint($latitude, $longitude)';
  }
}

/// An immutable object representing an array of bytes.
class Blob {
  final Uint8List _data;

  /// Creates new  blob from list of bytes in [data].
  Blob(List<int> data) : _data = Uint8List.fromList(data);

  /// Creates new blob from list of bytes in [Uint8List].
  Blob.fromUint8List(this._data);

  /// List of bytes contained in this blob.
  List<int> get data => _data;

  /// Returns byte data in this blob as an instance of [Uint8List].
  Uint8List asUint8List() => _data;
}

/// A QuerySnapshot contains zero or more DocumentSnapshot objects.
class QuerySnapshot {
  QuerySnapshot(this.nativeInstance, this.firestore);

  @protected
  final js.QuerySnapshot nativeInstance;
  final Firestore firestore;

  bool get isEmpty => nativeInstance.empty;

  bool get isNotEmpty => !isEmpty;

  /// Gets a list of all the documents included in this snapshot
  List<DocumentSnapshot>? get documents {
    if (isEmpty) return const <DocumentSnapshot>[];
    _documents ??= List<js.QueryDocumentSnapshot>.from(nativeInstance.docs)
        .map((jsDoc) => DocumentSnapshot(jsDoc, firestore))
        .toList(growable: false);
    return _documents;
  }

  List<DocumentSnapshot>? _documents;

  /// An array of the documents that changed since the last snapshot. If this
  /// is the first snapshot, all documents will be in the list as Added changes.
  List<DocumentChange>? get documentChanges {
    if (_changes == null) {
      if (nativeInstance.docChanges() == null) {
        _changes = const <DocumentChange>[];
      } else {
        _changes = List<js.DocumentChange>.from(nativeInstance.docChanges()!)
            .map((jsChange) => DocumentChange(jsChange, firestore))
            .toList(growable: false);
      }
    }
    return _changes;
  }

  List<DocumentChange>? _changes;
}

/// Represents a query over the data at a particular location.
class DocumentQuery {
  DocumentQuery(this.nativeInstance, this.firestore);

  @protected
  final js.DocumentQuery? nativeInstance;
  final Firestore firestore;

  Future<QuerySnapshot> get() {
    return node
        .promiseToFuture<js.QuerySnapshot>(nativeInstance!.get())
        .then((jsSnapshot) => QuerySnapshot(jsSnapshot, firestore));
  }

  /// Notifies of query results at this location.
  Stream<QuerySnapshot> get snapshots {
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    late StreamController<QuerySnapshot> controller; // ignore: close_sinks

    void onSnapshot(js.QuerySnapshot snapshot) {
      controller.add(QuerySnapshot(snapshot, firestore));
    }

    void onError(Object error) {
      controller.addError(error);
    }

    late Function unsubscribe;

    controller = StreamController<QuerySnapshot>.broadcast(
      onListen: () {
        unsubscribe = nativeInstance!
            .onSnapshot(allowInterop(onSnapshot), allowInterop(onError));
      },
      onCancel: () {
        (unsubscribe as dynamic Function())();
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
    dynamic arrayContains,
    bool? isNull,
    List? whereIn,
    List? notIn,
    List? arrayContainsAny,
  }) {
    var query = nativeInstance;

    void addCondition(String field, String opStr, dynamic value) {
      query = query!.where(field, opStr, _FirestoreData._jsify(value));
    }

    if (isEqualTo != null) addCondition(field, '==', isEqualTo);
    if (isLessThan != null) addCondition(field, '<', isLessThan);
    if (isLessThanOrEqualTo != null) {
      addCondition(field, '<=', isLessThanOrEqualTo);
    }
    if (isGreaterThan != null) addCondition(field, '>', isGreaterThan);
    if (isGreaterThanOrEqualTo != null) {
      addCondition(field, '>=', isGreaterThanOrEqualTo);
    }
    if (arrayContains != null) {
      addCondition(field, 'array-contains', arrayContains);
    }
    if (whereIn != null) {
      addCondition(field, 'in', whereIn);
    }
    if (notIn != null) {
      addCondition(field, 'not-in', whereIn);
    }
    if (arrayContainsAny != null) {
      addCondition(field, 'array-contains-any', arrayContainsAny);
    }

    if (isNull != null) {
      assert(
          isNull,
          'isNull can only be set to true. '
          'Use isEqualTo to filter on non-null values.');
      addCondition(field, '==', null);
    }

    return DocumentQuery(query, firestore);
  }

  /// Creates and returns a new [DocumentQuery] that's additionally sorted by the specified
  /// [field].
  DocumentQuery orderBy(String field, {bool descending = false}) {
    var direction = descending ? 'desc' : 'asc';
    return DocumentQuery(nativeInstance!.orderBy(field, direction), firestore);
  }

  /// Creates and returns a new [DocumentQuery] sorted by id. (no other sort order allowed)
  DocumentQuery orderByKey({bool descending = false}) {
    var direction = descending ? 'desc' : 'asc';
    return DocumentQuery(
        nativeInstance!
            .orderBy(js.admin!.firestore.FieldPath.documentId(), direction),
        firestore);
  }

  /// Takes a [snapshot] or a list of [values], creates and returns a new [DocumentQuery]
  /// that starts after the provided fields relative to the order of the query.
  ///
  /// Either [snapshot] or [values] can be provided at the same time, not both.
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [startAt].
  DocumentQuery startAfter(
      {DocumentSnapshot? snapshot, List<dynamic>? values}) {
    return DocumentQuery(
        _wrapPaginatingFunctionCall('startAfter', snapshot, values), firestore);
  }

  /// Takes a [snapshot] or a list of [values], creates and returns a new [DocumentQuery]
  /// that starts at the provided fields relative to the order of the query.
  ///
  /// Either [snapshot] or [values] can be provided at the same time, not both.
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [startAfter].
  DocumentQuery startAt({DocumentSnapshot? snapshot, List<dynamic>? values}) {
    return DocumentQuery(
        _wrapPaginatingFunctionCall('startAt', snapshot, values), firestore);
  }

  /// Takes a [snapshot] or a list of [values], creates and returns a new [DocumentQuery]
  /// that ends at the provided fields relative to the order of the query.
  ///
  /// Either [snapshot] or [values] can be provided at the same time, not both.
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [endBefore].
  DocumentQuery endAt({DocumentSnapshot? snapshot, List<dynamic>? values}) {
    return DocumentQuery(
        _wrapPaginatingFunctionCall('endAt', snapshot, values), firestore);
  }

  /// Takes a [snapshot] or a list of [values], creates and returns a new [DocumentQuery]
  /// that ends before the provided fields relative to the order of the query.
  ///
  /// Either [snapshot] or [values] can be provided at the same time, not both.
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [endAt].
  DocumentQuery endBefore({DocumentSnapshot? snapshot, List<dynamic>? values}) {
    return DocumentQuery(
        _wrapPaginatingFunctionCall('endBefore', snapshot, values), firestore);
  }

  /// Creates and returns a new Query that's additionally limited to only return up
  /// to the specified number of documents.
  DocumentQuery limit(int length) {
    return DocumentQuery(nativeInstance!.limit(length), firestore);
  }

  /// Specifies the offset of the returned results.
  DocumentQuery offset(int offset) {
    return DocumentQuery(nativeInstance!.offset(offset), firestore);
  }

  /// Calls js paginating [method] with [DocumentSnapshot] or List of [values].
  /// We need to call this method in all paginating methods to fix that Dart
  /// doesn't support varargs - we need to use [List] to call js function.
  js.DocumentQuery? _wrapPaginatingFunctionCall(
      String method, DocumentSnapshot? snapshot, List<dynamic>? values) {
    if (snapshot == null && values == null) {
      throw ArgumentError(
          'Please provide either snapshot or values parameter.');
    } else if (snapshot != null && values != null) {
      throw ArgumentError(
          'Cannot provide both snapshot and values parameters.');
    }
    var args = (snapshot != null)
        ? [snapshot.nativeInstance]
        : values!.map(_FirestoreData._jsify).toList();
    return node.callMethod(nativeInstance!, method, args) as js.DocumentQuery;
  }

  /// Creates and returns a new Query instance that applies a field mask
  /// to the result and returns only the specified subset of fields.
  /// You can specify a list of field paths to return, or use an empty
  /// list to only return the references of matching documents.
  DocumentQuery select(List<String> fieldPaths) {
    //  Dart doesn't support varargs
    return DocumentQuery(
        node.callMethod(nativeInstance!, 'select', fieldPaths)
            as js.DocumentQuery,
        firestore);
  }
}

/// A reference to a transaction.
/// The [Transaction] object passed to a transaction's updateFunction provides
/// the methods to read and write data within the transaction context. See
/// [Firestore.runTransaction].
class Transaction {
  final js.Transaction nativeInstance;

  Transaction(this.nativeInstance);

  /// Reads the document referenced by the provided [documentRef].
  /// Holds a pessimistic lock on the returned document.
  Future<DocumentSnapshot> get(DocumentReference documentRef) {
    final nativeRef = documentRef.nativeInstance;
    return node
        .promiseToFuture<js.DocumentSnapshot>(nativeInstance.get(nativeRef))
        .then((jsSnapshot) =>
            DocumentSnapshot(jsSnapshot, documentRef.firestore));
  }

  /// Retrieves a query result. Holds a pessimistic lock on the returned
  /// documents.
  Future<QuerySnapshot> getQuery(DocumentQuery query) {
    final nativeQuery = query.nativeInstance;
    return node
        .promiseToFuture<js.QuerySnapshot>(nativeInstance.get(nativeQuery))
        .then((jsSnapshot) => QuerySnapshot(jsSnapshot, query.firestore));
  }

  /// Create the document referred to by the provided [documentRef].
  /// The operation will fail the transaction if a document exists at the
  /// specified location.
  void create(DocumentReference documentRef, DocumentData data) {
    var docData = data.nativeInstance;
    var nativeRef = documentRef.nativeInstance;
    nativeInstance.create(nativeRef, docData);
  }

  /// Writes to the document referred to by the provided [documentRef].
  /// If the document does not exist yet, it will be created. If you pass
  /// [options], the provided data can be merged into the existing document.
  void set(DocumentReference documentRef, DocumentData data,
      {bool merge = false}) {
    final docData = data.nativeInstance;
    final nativeRef = documentRef.nativeInstance;
    nativeInstance.set(nativeRef, docData, _getNativeSetOptions(merge));
  }

  /// Updates fields in the document referred to by the provided [documentRef].
  ///
  /// The update will fail if applied to a document that does not exist.
  /// [lastUpdateTime] argument can be used to add a precondition for this
  /// update. This argument, if specified, must contain value of
  /// [DocumentSnapshot.updateTime]. The update will be accepted only if
  /// update time on the server is equal to this value.
  void update(DocumentReference documentRef, UpdateData data,
      {Timestamp? lastUpdateTime}) {
    final docData = data.nativeInstance;
    final nativeRef = documentRef.nativeInstance;
    if (lastUpdateTime != null) {
      nativeInstance.update(
          nativeRef, docData, _getNativePrecondition(lastUpdateTime));
    } else {
      nativeInstance.update(nativeRef, docData);
    }
  }

  /// Deletes the document referred to by the provided [documentRef].
  ///
  /// [lastUpdateTime] argument can be used to add a precondition for this
  /// delete. This argument, if specified, must contain value of
  /// [DocumentSnapshot.updateTime]. The delete will be accepted only if
  /// update time on the server is equal to this value.
  void delete(DocumentReference documentRef, {Timestamp? lastUpdateTime}) {
    final nativeRef = documentRef.nativeInstance;
    if (lastUpdateTime != null) {
      nativeInstance.delete(nativeRef, _getNativePrecondition(lastUpdateTime));
    } else {
      nativeInstance.delete(nativeRef);
    }
  }
}

/// A write batch, used to perform multiple writes as a single atomic unit.
///
/// A [WriteBatch] object can be acquired by calling [Firestore.batch]. It
/// provides methods for adding writes to the write batch. None of the
/// writes will be committed (or visible locally) until [WriteBatch.commit]
/// is called.
///
/// Unlike transactions, write batches are persisted offline and therefore are
/// preferable when you don't need to condition your writes on read data.
class WriteBatch {
  final js.WriteBatch nativeInstance;

  WriteBatch(this.nativeInstance);

  /// Write to the document referred to by the provided [documentRef].
  /// If the document does not exist yet, it will be created. If you pass
  /// [options], the provided data can be merged into the existing document.
  void setData(DocumentReference documentRef, DocumentData data,
      [js.SetOptions? options]) {
    final docData = data.nativeInstance;
    final nativeRef = documentRef.nativeInstance;
    if (options != null) {
      nativeInstance.set(nativeRef, docData, options);
    } else {
      nativeInstance.set(nativeRef, docData);
    }
  }

  /// Updates fields in the document referred to by this [documentRef].
  /// The update will fail if applied to a document that does not exist.
  ///
  /// Nested fields can be updated by providing dot-separated field path strings.
  void updateData(DocumentReference documentRef, UpdateData data) =>
      nativeInstance.update(
          documentRef.nativeInstance, data.nativeInstance as js.UpdateData?);

  /// Deletes the document referred to by the provided [documentRef].
  void delete(DocumentReference documentRef) =>
      nativeInstance.delete(documentRef.nativeInstance);

  /// Commits all of the writes in this write batch as a single atomic unit.
  Future commit() => node.promiseToFuture(nativeInstance.commit());
}

/// An options object that configures conditional behavior of [update] and
/// [delete] calls in [DocumentReference], [WriteBatch], and [Transaction].
/// Using Preconditions, these calls can be restricted to only apply to
/// documents that match the specified restrictions.
js.Precondition _getNativePrecondition(Timestamp lastUpdateTime) {
  final ts = _createJsTimestamp(lastUpdateTime);
  return js.Precondition(lastUpdateTime: ts);
}

/// An options object that configures the behavior of [set] calls in
/// [DocumentReference], [WriteBatch] and [Transaction]. These calls can be
/// configured to perform granular merges instead of overwriting the target
/// documents in their entirety by providing a [SetOptions] with [merge]: true.
js.SetOptions _getNativeSetOptions(bool merge) {
  //assert(merge != null, 'SetOption merge can`t be null');
  return js.SetOptions(merge: merge);
}

class _FieldValueDelete implements FieldValue {
  @override
  dynamic _jsify() {
    return js.admin!.firestore.FieldValue.delete();
  }

  @override
  String toString() => 'FieldValue.delete()';
}

class _FieldValueServerTimestamp implements FieldValue {
  @override
  dynamic _jsify() {
    return js.admin!.firestore.FieldValue.serverTimestamp();
  }

  @override
  String toString() => 'FieldValue.serverTimestamp()';
}

abstract class _FieldValueArray implements FieldValue {
  final List elements;

  _FieldValueArray(this.elements);
}

class _FieldValueArrayUnion extends _FieldValueArray {
  _FieldValueArrayUnion(super.elements);

  @override
  dynamic _jsify() {
    return node.callMethod<Object?>(js.admin!.firestore.FieldValue,
        'arrayUnion', _FirestoreData._jsifyList(elements));
  }

  @override
  String toString() => 'FieldValue.arrayUnion($elements)';
}

class _FieldValueArrayRemove extends _FieldValueArray {
  _FieldValueArrayRemove(super.elements);

  @override
  dynamic _jsify() {
    return node.callMethod<Object?>(js.admin!.firestore.FieldValue,
        'arrayRemove', _FirestoreData._jsifyList(elements));
  }

  @override
  String toString() => 'FieldValue.arrayRemove($elements)';
}

/// Sentinel values that can be used when writing document fields with set()
/// or update().
abstract class FieldValue {
  factory FieldValue._fromJs(dynamic jsFieldValue) {
    if (jsFieldValue == js.admin!.firestore.FieldValue.delete()) {
      return Firestore.fieldValues.delete();
    } else if (jsFieldValue ==
        js.admin!.firestore.FieldValue.serverTimestamp()) {
      return Firestore.fieldValues.serverTimestamp();
    } else {
      throw ArgumentError.value(jsFieldValue, 'jsFieldValue',
          "Invalid value provided. We don't support dartfying object like arrayUnion or arrayRemove since not needed");
    }
  }

  dynamic _jsify();
}

class FieldValues {
  /// Returns a sentinel used with set() or update() to include a
  /// server-generated timestamp in the written data.
  FieldValue serverTimestamp() => _serverTimestamp;

  /// Returns a sentinel for use with update() to mark a field for deletion.
  FieldValue delete() => _delete;

  /// Returns a special value that tells the server to union the given elements
  /// with any array value that already exists on the server.
  ///
  /// Can be used with set(), create() or update() operations.
  ///
  /// Each specified element that doesn't already exist in the array will be
  /// added to the end. If the field being modified is not already an array it
  /// will be overwritten with an array containing exactly the specified
  /// elements.
  FieldValue arrayUnion(List elements) => _FieldValueArrayUnion(elements);

  /// Returns a special value that tells the server to remove the given elements
  /// from any array value that already exists on the server.
  ///
  /// Can be used with set(), create() or update() operations.
  ///
  /// All instances of each element specified will be removed from the array.
  /// If the field being modified is not already an array it will be overwritten
  /// with an empty array.
  FieldValue arrayRemove(List elements) => _FieldValueArrayRemove(elements);

  FieldValues._();

  final FieldValue _serverTimestamp = _FieldValueServerTimestamp();
  final FieldValue _delete = _FieldValueDelete();
}
