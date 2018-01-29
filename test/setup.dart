// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:node_interop/node.dart';
import 'package:node_interop/util.dart';
import 'package:node_interop/test.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';

final Map<String, String> env = dartify(process.env);

App initFirebaseApp() {
  if (!env.containsKey('FIREBASE_PROJECT_ID') ||
      !env.containsKey('FIREBASE_CLIENT_EMAIL') ||
      !env.containsKey('FIREBASE_PRIVATE_KEY') ||
      !env.containsKey('FIREBASE_DATABASE_URL'))
    throw new StateError('Environment variables are not set.');

  installNodeModules({"firebase-admin": "~4.2.1"});

  var cert = FirebaseAdmin.instance.cert(
    projectId: env['FIREBASE_PROJECT_ID'],
    clientEmail: env['FIREBASE_CLIENT_EMAIL'],
    privateKey: env['FIREBASE_PRIVATE_KEY'].replaceAll(r'\n', '\n'),
  );
  return FirebaseAdmin.instance.initializeApp(new AppOptions(
      credential: cert, databaseURL: env['FIREBASE_DATABASE_URL']));
}
