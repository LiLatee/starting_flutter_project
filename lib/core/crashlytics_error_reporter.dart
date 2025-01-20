// ignore_for_file: comment_references

import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:starting_flutter_project/core/dependencies.dart';

class CrashlyticsErrorReporter {
  CrashlyticsErrorReporter({this.isReleaseMode = kReleaseMode});

  /// Set it to true if you want to test if your errors are sent to Firebase.
  final bool isReleaseMode;

  Future<dynamic> initReporter() async {
    FlutterError.onError = _reportFlutterError;
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
      return true;
    };

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(isReleaseMode);
  }

  Future<void> logException({
    required Object exception,
    required StackTrace stackTrace,
  }) {
    if (isReleaseMode) {
      return FirebaseCrashlytics.instance.recordError(exception, stackTrace);
    } else {
      return _printException(exception: exception, stackTrace: stackTrace);
    }
  }

  Future<void> _reportFlutterError(FlutterErrorDetails flutterErrorDetails) async {
    if (isReleaseMode) {
      return FirebaseCrashlytics.instance.recordFlutterError(flutterErrorDetails);
    } else {
      return _printException(exception: flutterErrorDetails.exception, stackTrace: flutterErrorDetails.stack);
    }
  }

  Future<void> _printException({
    required Object exception,
    StackTrace? stackTrace,
  }) async {
    _printInRed('[🔥] Crashlytics Error reporter - debug mode, only printing');
    _printInRed(exception.toString());
    _printInRed(stackTrace.toString());
  }

  void _printInRed(String text) {
    if (kDebugMode) {
      debugPrintThrottled('\x1B[31m$text\x1B[0m', wrapWidth: 120);
    }
  }
}

/// In order to make it useful during development (in debug mode) remember to set
Future<void> testFirebaseCrashlytics() async {
  await sl<CrashlyticsErrorReporter>()
      .logException(exception: Exception('Test: non-fatal'), stackTrace: StackTrace.current);
  await FirebaseCrashlytics.instance
      .recordFlutterError(FlutterErrorDetails(exception: Exception('Test: fatal')), fatal: true);
  FirebaseCrashlytics.instance.crash();
}
