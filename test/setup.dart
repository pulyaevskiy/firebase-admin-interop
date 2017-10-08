import 'package:node_interop/node_interop.dart';
import 'package:node_interop/test.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';

final platform = new NodePlatform();
final Map<String, String> env = platform.environment;

App initFirebaseApp() {
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
