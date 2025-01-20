import 'package:get_it/get_it.dart';
import 'package:starting_flutter_project/core/crashlytics_error_reporter.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  final CrashlyticsErrorReporter crashlyticsErrorReporter = CrashlyticsErrorReporter();
  await crashlyticsErrorReporter.initReporter();
  sl.registerLazySingleton(() => crashlyticsErrorReporter);
}
