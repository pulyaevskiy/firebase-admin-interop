// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:node_interop/node_interop.dart';

final Map<String, String> env = node.platform.environment;

main() async {
  var admin = new FirebaseAdmin();
  App app = admin.initializeApp(
    credential: admin.credential.cert(
      projectId: env['FIREBASE_PROJECT_ID'],
      clientEmail: env['FIREBASE_CLIENT_EMAIL'],
      privateKey: env['FIREBASE_PRIVATE_KEY'].replaceAll(r'\n', '\n'),
    ),
    databaseURL: env['FIREBASE_DATABASE_URL'],
  );

  var ref = app.database().ref('/test');
  print('Ref: ${ref.key}');

  // Write to `/test`
  await ref.set('Write to Firebase from Dart');

  // Read from `/test`
  DataSnapshot snapshot = await ref.once('value');
  print('Exists: ${snapshot.exists()}');
  print('Has children: ${snapshot.hasChildren()}');
  print('Num children: ${snapshot.numChildren()}');
  print('Key: ${snapshot.key}');
  print('Value: ${snapshot.val()}');

  await app.delete(); // releases all open connections
}
