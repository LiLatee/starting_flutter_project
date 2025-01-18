#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      'path',
      help: 'The path to the directory containing all *.arb files.',
      valueHelp: 'lib/l10n/arb',
      defaultsTo: 'lib/l10n/arb',
    )
    ..addOption(
      'main-language-code',
      help: 'The main language that should be used as the source of truth in all translations.',
      valueHelp: 'en',
      defaultsTo: 'en',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Displays this help information.',
    );

  final ArgResults argResults = parser.parse(args);

  // Handle the --help flag
  if (argResults['help'] as bool) {
    printInColor('Usage: ${Platform.script.pathSegments.last} [options]');
    printInColor(parser.usage);
    return;
  }

  final String path = argResults['path'] as String;
  final String mainLanguageCode = argResults['main-language-code'] as String;

  printInColor('Path: $path', color: PrintColor.blue);
  printInColor('Name: $mainLanguageCode', color: PrintColor.blue);

  final Directory arbFilesDirectory = Directory(path);
  if (!await arbFilesDirectory.exists()) {
    printInColor('Directory does not exist: $path', color: PrintColor.red);
    return;
  }

  final FileSystemEntity mainArbFile =
      await arbFilesDirectory.list().firstWhere((file) => file.path.contains(mainLanguageCode));

  final Set<String> requiredKeys = await extractKeysFromARB(path: mainArbFile.path);

  // Loop over all ARB files and compare each of the to the main file.
  final Map<String, Set<String>> results = {};
  await for (final FileSystemEntity arbFile in arbFilesDirectory.list()) {
    if (arbFile == mainArbFile) {
      continue;
    }

    if (arbFile is! File) {
      printInColor('${arbFile.path} is not a proper File. Skipping...', color: PrintColor.red);
    }

    final Set<String> processedKeys = await extractKeysFromARB(path: arbFile.path);
    final Set<String> differenceKeys = requiredKeys.difference(processedKeys);

    if (differenceKeys.isNotEmpty) {
      results[arbFile.path] = differenceKeys;
    }
  }

  if (results.isEmpty) {
    exit(0);
  } else {
    for (final MapEntry<String, Set<String>> entry in results.entries) {
      printInColor('${entry.key} file lacks:', color: PrintColor.green);
      for (final String key in entry.value) {
        printInColor('$key');
      }
    }
    exit(1);
  }
}

Future<Set<String>> extractKeysFromARB({
  required String path,
}) async {
  final File file = File(path);
  if (!await file.exists()) {
    printInColor('File not found: $path', color: PrintColor.red);
    exit(1);
  }

  final String content = await file.readAsString();

  final Map<String, dynamic> jsonContent = json.decode(content) as Map<String, dynamic>;
  final Set<String> requiredKeys = jsonContent.keys.map((e) => e.replaceAll('@', '')).toSet();

  return requiredKeys;
}

enum PrintColor {
  red(colorCode: "\x1b[31m"),
  green(colorCode: "\x1b[32m"),
  yellow(colorCode: "\x1b[33m"),
  blue(colorCode: "\x1b[34m"),
  white(colorCode: "\x1b[37m"),
  reset(colorCode: "\x1b[0m");

  const PrintColor({required this.colorCode});

  final String colorCode;
}

void printInColor(String text, {PrintColor color = PrintColor.reset}) => print('${color.colorCode}$text\x1b[0m');
