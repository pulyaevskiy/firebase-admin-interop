// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:node_interop/node.dart' as node;
import 'package:node_interop/util.dart' as node;

final Map env = node.dartify(node.process.env);

App? initFirebaseApp() {
  if (!env.containsKey('FIREBASE_CONFIG') ||
      !env.containsKey('FIREBASE_SERVICE_ACCOUNT_JSON')) {
    throw StateError('Environment variables are not set.');
  }

  var certConfig =
      jsonDecode(env['FIREBASE_SERVICE_ACCOUNT_JSON'] as String) as Map;
  final cert = FirebaseAdmin.instance.cert(
    projectId: certConfig['project_id'] as String?,
    clientEmail: certConfig['client_email'] as String?,
    privateKey: certConfig['private_key'] as String?,
  );
  final config = jsonDecode(env['FIREBASE_CONFIG'] as String) as Map;
  final databaseUrl = config['databaseURL'] as String?;
  return FirebaseAdmin.instance
      .initializeApp(AppOptions(credential: cert, databaseURL: databaseUrl));
}
