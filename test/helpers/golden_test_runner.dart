import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_test/golden_test.dart';
import 'package:meta/meta.dart';
import 'package:starting_flutter_project/l10n/l10n.dart';

@isTest
Future<void> runGoldenTest(
  Object name, {
  required Widget Function(BuildContext context) builder,
  String? path,
  bool? skip,
}) async {
  final router = GoRouter(
    routes: [GoRoute(path: path ?? '/', builder: (context, __) => builder(context))],
    initialLocation: path ?? '/',
  );

  goldenTest(
    name: name.toString(),
    skip: skip ?? false,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedThemes: [
      Brightness.light,
      Brightness.dark,
    ],
    supportedDevices: [const Device.noInsets()],
    supportedLocales: AppLocalizations.supportedLocales,
    routerDelegate: router.routerDelegate,
    routeInformationProvider: router.routeInformationProvider,
    routeInformationParser: router.routeInformationParser,
  );
}
