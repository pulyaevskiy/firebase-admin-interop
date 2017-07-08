// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:firebase_admin_interop/firebase_admin_interop.dart';

main() async {
  var admin = new FirebaseAdmin();
  var creds = appCredentials;
  var app = admin.initializeApp(new AppOptions(
    credential: admin.credential.cert(creds),
    databaseUrl: const String.fromEnvironment('FIREBASE_DATABASE_URL'),
  ));

  var ref = admin.database().ref('/test');
  print('Ref: ${ref.key}');
  var snapshot = await ref.once('value');
  print('Exists: ${snapshot.exists()}');
  print('Has children: ${snapshot.hasChildren()}');
  print('Num children: ${snapshot.numChildren()}');
  print('Key: ${snapshot.key}');
  print('Value: ${snapshot.val()}');
  await app.delete();
}

Map<String, String> get appCredentials {
  return {
    'project_id': const String.fromEnvironment('FIREBASE_PROJECT_ID'),
    'client_email': const String.fromEnvironment('FIREBASE_CLIENT_EMAIL'),
    'private_key': const String.fromEnvironment('FIREBASE_PRIVATE_KEY')
        .replaceAll(r'\n', '\n'),
  };
}
