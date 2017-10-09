import 'package:node_interop/node_interop.dart';
import 'package:node_interop/test.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';

final Map<String, String> env = node.platform.environment;

App initFirebaseApp() {
  if (!env.containsKey('FIREBASE_PROJECT_ID') ||
      !env.containsKey('FIREBASE_CLIENT_EMAIL') ||
      !env.containsKey('FIREBASE_PRIVATE_KEY') ||
      !env.containsKey('FIREBASE_DATABASE_URL'))
    throw new StateError('Environment variables are not set.');

  installNodeModules({"firebase-admin": "~4.2.1"});

  var admin = new FirebaseAdmin();
  return admin.initializeApp(
    credential: admin.credential.cert(
      projectId: env['FIREBASE_PROJECT_ID'],
      clientEmail: env['FIREBASE_CLIENT_EMAIL'],
      privateKey: env['FIREBASE_PRIVATE_KEY'].replaceAll(r'\n', '\n'),
    ),
    databaseURL: env['FIREBASE_DATABASE_URL'],
  );
}
