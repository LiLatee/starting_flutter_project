import 'package:starting_flutter_project/app/app.dart';
import 'package:starting_flutter_project/bootstrap.dart';
import 'package:starting_flutter_project/firebase_options_prod.dart';

void main() {
  bootstrap(
    () => const App(),
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}
