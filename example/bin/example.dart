// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:node_interop/node_interop.dart';

main() async {
  var admin = new FirebaseAdmin();
  App app = admin.initializeApp(new AppOptions(
    credential: admin.credential.cert(appCredentials),
    databaseUrl: env['FIREBASE_DATABASE_URL'],
  ));

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

final NodePlatform platform = new NodePlatform();
final Map<String, String> env = platform.environment;

Map<String, String> get appCredentials {
  return {
    'project_id': env['FIREBASE_PROJECT_ID'],
    'client_email': env['FIREBASE_CLIENT_EMAIL'],
    'private_key': env['FIREBASE_PRIVATE_KEY'].replaceAll(r'\n', '\n'),
  };
}
