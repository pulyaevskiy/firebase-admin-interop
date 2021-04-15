// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:node_interop/node.dart';
import 'package:node_interop/util.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';

final Map env = dartify(process.env);

App? initFirebaseApp() {
  if (!env.containsKey('FIREBASE_CONFIG') ||
      !env.containsKey('FIREBASE_SERVICE_ACCOUNT_JSON'))
    throw new StateError('Environment variables are not set.');

  Map certConfig = jsonDecode(env['FIREBASE_SERVICE_ACCOUNT_JSON']);
  final cert = FirebaseAdmin.instance.cert(
    projectId: certConfig['project_id'],
    clientEmail: certConfig['client_email'],
    privateKey: certConfig['private_key'],
  );
  final Map config = jsonDecode(env['FIREBASE_CONFIG']);
  final databaseUrl = config['databaseURL'];
  return FirebaseAdmin.instance.initializeApp(
      new AppOptions(credential: cert, databaseURL: databaseUrl));
}
