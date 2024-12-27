import 'package:starting_flutter_project/app/app.dart';
import 'package:starting_flutter_project/bootstrap.dart';
import 'package:starting_flutter_project/firebase_options_stg.dart';

void main() {
  bootstrap(
    () => const App(),
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}

// echo "FLAVOR: $FLAVOR"
// echo "BUILT_PRODUCTS_DIR: $BUILT_PRODUCTS_DIR"
// echo "SRCROOT: $SRCROOT"
// echo "CONFIGURATION: $CONFIGURATION"
// cp "${SRCROOT}/flavors/${FLAVOR}/GoogleService-Info.plist" "${SRCROOT}/${PRODUCT_NAME}"
