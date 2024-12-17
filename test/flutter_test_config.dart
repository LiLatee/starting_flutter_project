import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_test/golden_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart' as golden_toolkit;
import 'package:intl/intl.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Fixes fonts and Icons on goldens.
  await golden_toolkit.loadAppFonts();

  globalSetup = (locale) async => Intl.systemLocale = locale.languageCode;

  /// Should solve problems with differences in generating goldens on different systems e.g. local vs CI.
  goldenTestDifferenceTolerance(0.06);

  return testMain();
}
