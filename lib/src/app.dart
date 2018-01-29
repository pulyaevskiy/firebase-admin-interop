// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:node_interop/util.dart';

import 'bindings.dart' as js;
import 'database.dart';

/// Represents initialized Firebase application and provides access to the
/// app's services.
class App {
  final js.App nativeInstance;

  App(this.nativeInstance);

  /// The name of this application.
  String get name => nativeInstance.name;

  /// Returns Realtime [Database] client for this application.
  Database database() => _database ??= new Database.forApp(this);
  Database _database;

  /// Renders this app unusable and frees the resources of all associated
  /// services.
  Future<Null> delete() => promiseToFuture(nativeInstance.delete());
}
