import 'dart:async';
import 'dart:js' as js;

import 'package:node_interop/node_interop.dart';

import 'bindings/core.dart';
import 'bindings/database.dart';

class Database {
  final JsDatabase _inner;

  Database(this._inner);

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

class DataSnapshot {
  final JsDataSnapshot _inner;

  DataSnapshot._(this._inner);

  String get key => _inner.key;

  Reference get ref => new Reference._(_inner.ref);

  DataSnapshot child(String path) => new DataSnapshot._(_inner.child(path));

  bool exists() => _inner.exists();

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
