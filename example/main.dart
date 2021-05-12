import 'package:firebase_admin_interop/firebase_admin_interop.dart';

main() async {
  final serviceAccountKeyFilename = '/absolute/path/to/service-account.json';
  final admin = FirebaseAdmin.instance;
  final cert = admin.certFromPath(serviceAccountKeyFilename);
  final app = admin.initializeApp(AppOptions(
    credential: cert,
    databaseURL: "YOUR_DB_URL",
  ));
  final ref = app.database().ref('/test-path');
  // Write value to the database at "/test-path" location.
  await ref.setValue("Hello world");
  // Read value from the same database location.
  var snapshot = await ref.once("value");
  print(snapshot.val()); // prints "Hello world".
}
