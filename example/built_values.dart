// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:node_interop/node_interop.dart';

import 'src/serializers.dart';
import 'src/values.dart';

final Map<String, String> env = node.platform.environment;

/// Example of using built_value generated models and serializers.
main() async {
  // Make sure to export all required env variables before running this app.
  var cert = FirebaseAdmin.instance.cert(
    projectId: env['FIREBASE_PROJECT_ID'],
    clientEmail: env['FIREBASE_CLIENT_EMAIL'],
    privateKey: env['FIREBASE_PRIVATE_KEY'].replaceAll(r'\n', '\n'),
  );

  App app = FirebaseAdmin.instance.initializeApp(new AppOptions(
    credential: cert,
    databaseURL: env['FIREBASE_DATABASE_URL'],
  ));

  // Must make this library aware of the app's "built_value" models and
  // serializers.
  FirebaseAdmin.instance.registerSerializers(serializers);

  var ref = app.database().ref('/built-value/memo');

  // Write to ref
  var memo = new Memo((builder) {
    builder.id = 23;
    builder.title = 'Built Memo';
    builder.createdAt = new DateTime.now().toUtc();
  });
  await ref.setValue(memo, Memo.serializer);

  // Read from ref
  DataSnapshot<Memo> snapshot = await ref.once<Memo>('value', Memo.serializer);
  Memo storedMemo = snapshot.val();
  print('Value: ${storedMemo}');

  await app.delete(); // releases all open connections
}
