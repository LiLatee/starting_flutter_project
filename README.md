# Starting Flutter Project

![coverage][coverage_badge]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

Template for starting Flutter app based on [Very Good CLI][very_good_cli_link] with some additional stuff.
The goal of that is to use [Very Good CLI][very_good_cli_link] and then apply belowe instructions in order to add some additional stuff. In the future the idea is to create an automatic script/package for that.

---

- [Version manager](#version-manager)
- [Secrets](#secrets)
  * [Preperations](#preperations)
    + [Add new rules to gitignore in the main directory of a project](#add-new-rules-to-gitignore-in-the-main-directory-of-a-project)
  * [Variables](#variables)
  * [Files](#files)
  * [iOS](#ios)
    + [Info.plist](#infoplist)
    + [AppDelegate.swift](#appdelegateswift)
  * [Android](#android)
    + [build.gradle and AndroidManifest](#buildgradle-and-androidmanifest)
    + [MainActivity.kt](#mainactivitykt)
- [Golden - Screenshot Tests](#golden---screenshot-tests)
- [Linter](#linter)
- [Githooks](#githooks)
    + [pre-commit](#pre-commit)
    + [pre-push](#pre-push)
- [Helpful scripts](#helpful-scripts)
- [Github Workflows](#github-workflows)
  * [Test and Analyze workflow](#test-and-analyze-workflow)
- [Getting Started 🚀](#getting-started---)
- [Running Tests 🧪](#running-tests---)
- [Working with Translations 🌐](#working-with-translations---)
  * [Adding Strings](#adding-strings)
  * [Adding Supported Locales](#adding-supported-locales)
  * [Adding Translations](#adding-translations)
  * [Generating Translations](#generating-translations)
- [TODO LIST](#todo-list)

# Version manager
This project uses [mise](https://mise.jdx.dev/) for managing version of Flutter and other required tools. [asdf](https://asdf-vm.com/) should also work fine.

 `.tool-versions` file in root project directory defines Flutter version used for that project. Install [mise](https://mise.jdx.dev/) and type the following command to install that Flutter version.
```bash
mise install
```

# Secrets

## Preperations

### Add new rules to gitignore in the main directory of a project

```
# Secrets
secrets/keys
secrets/encryption_password.txt
/lib/core/envs/env.g.dart
```
## Variables

Secrets are kept in `keys/*.env` files. Respectively for the environment, these can be named like `staging.env` or `production.env`. The example file should look like this:

```
API_KEY=secret
```

This project uses [envied](https://pub.dev/packages/envied) to store private host URLs, private keys, etc. All the secrets have to be defined in `lib/core/env.dart` file. 

Add packages:
```bash
flutter pub add envied
flutter pub add dev:envied_generator
```

To generate the file run [build_runner](https://pub.dev/packages/build_runner):

```bash
dart run build_runner build --delete-conflicting-outputs
```



## Files

- All secret files and directoriee are stored in `secrets/encrypted_secrets.tar.gz.enc`.
- All secret files and directoriee are defined in `secrets/secret_files_list.txt`.
- `tools/secrets/encrypt_secrets.sh` script takes all the files defined in `secrets/secret_files_list.txt`, encrypts them and zips into `secrets/encrypted_secrets.tar.gz.enc`.
- `tools/secrets/decrypt_secrets.sh` script unzips all the files defined in `secrets/secret_files_list.txt` and places them in appropriate places.
- In order to use both above scripts you need to provide password in `secrets/encryption_password.txt`. In order to get password contact: marcin.hradowicz@gmail.com
You can generate a new password using that command `openssl rand -base64 16`.
- `tools/secrets/purge_secrets.sh` deletes all secrets defined in `secrets/secret_files_list.txt`.

## iOS

### Info.plist

In order to make your environment variables available in `ios/Runner/Info.plist` file (e.g. when adding integration with Facebook by adding `facebook_client_token` secret) you need to reproduce below steps from screenshots for EVERY environment `staging`, `production`, `development`.

![add_secrets_to_info_list_1](readme_resources/add_secrets_to_info_list_1.png)

![add_secrets_to_info_list_2](readme_resources/add_secrets_to_info_list_2.png)

`Copy .env to native code (so we can use it inside Info.plist) - part1`
```bash
echo "secrets/keys/staging.env" > ${SRCROOT}/.envfile
```

`Copy .env to native code (so we can use it inside Info.plist) - part2`
```bash
${SRCROOT}/.symlinks/plugins/flutter_config_plus/ios/Classes/BuildXCConfig.rb ${SRCROOT}/ ${SRCROOT}/Flutter/tmp.xcconfig
```

Then add [flutter_config_plus](https://pub.dev/packages/flutter_config_plus) package. It is used in above script.
```bash
flutter pub add flutter_config_plus
```

Next add this lines to `ios/Flutter/Debug.xcconfig` AND `ios/Flutter/Release.xcconfig`
```
// Config for storing .env inside native iOS code, so it can be used inside Info.plist.
#include "tmp.xcconfig"
```

Remember to add to `ios/.gitignore`
```
# These two files are used for storing .env inside native iOS code, so it can be used inside Info.plist.
/Flutter/tmp.xcconfig
/.envfile
```

Now you should be able to use your variables in `ios/Runner.Info.plist` like that:
```xml
<key>FacebookAppID</key>
<string>$(facebook_app_id)</string>
```

### AppDelegate.swift
Sometimes you need to access some secrets inside `AppDelegate.swift` file e.g. to set up [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) package. Firstly the secret has to be defined in `Info.plist` file as shown in the previous section. Then you can extract it in this way:

```swift
    let myCustomKey: String = Bundle.main.object(forInfoDictionaryKey:"FacebookAppID") as? String ?? ""

```

## Android

### build.gradle and AndroidManifest

In order to make your environment variables available in `android/app/build.gradle` file (e.g. when adding integration with Facebook by adding `facebook_client_token` secret) paste that code inside `android/app/build.gradle`

```gradle
//////////// ! Environment variables
def Properties flutterEnvProduction = new Properties()
def envFileProduction = file("../../secrets/keys/production.env")
if (envFileProduction.exists()) {
    flutterEnvProduction.load(new FileInputStream(envFileProduction))
}

def Properties flutterEnvDevelopment = new Properties()
def envFileDevelopment = file("../../secrets/keys/development.env")
if (envFileDevelopment.exists()) {
    flutterEnvDevelopment.load(new FileInputStream(envFileDevelopment))
}

def Properties flutterEnvStaging = new Properties()
def envFileStaging = file("../../secrets/keys/staging.env")
if (envFileStaging.exists()) {
    flutterEnvStaging.load(new FileInputStream(envFileStaging))
}
// Example of usage 
// flutterEnvStaging.getProperty('facebook_client_token')
//////////// !
```

then you can use it in `productFlavors` section.

Everything inside `manifestPlaceholders` is available in `AndroidManifest.xml` file.

```gradle
android {
        productFlavors {
            prod {
                dimension "default"
                applicationIdSuffix ""
                resValue "string", "facebook_client_token", flutterEnvProduction.getProperty('facebook_client_token')
                manifestPlaceholders = [
                    appName: "Starting Flutter Project", 
                    facebookContentProvider: "com.facebook.app.FacebookContentProvider${flutterEnvProduction.getProperty('facebook_app_id')}",
                    ]
            }
            staging {
                dimension "default"
                applicationIdSuffix ".stg"
                resValue "string", "facebook_client_token", flutterEnvStaging.getProperty('facebook_client_token')
                manifestPlaceholders = [
                    appName: "[STG] Starting Flutter Project",
                    facebookContentProvider: "com.facebook.app.FacebookContentProvider${flutterEnvStaging.getProperty('facebook_app_id')}",
                    ]
            }
            development {
                dimension "default"
                applicationIdSuffix ".dev"
                resValue "string", "facebook_client_token", flutterEnvStaging.getProperty('facebook_client_token')
                manifestPlaceholders = [
                    appName: "[DEV] Starting Flutter Project",
                    facebookContentProvider: "com.facebook.app.FacebookContentProvider${flutterEnvStaging.getProperty('facebook_app_id')}",
                    ]
            }
    }
}
```
### MainActivity.kt
In order to get access to secret inside `android/app/src/main/kotlin/com/lilatee/startingproject/starting/flutter/project/MainActivity.kt` file you need to add `resValue` property inside `productFlavors` in `android/app/build.gradle` file.

```gradle
    productFlavors { 
        staging {
            dimension "default"
            resValue "string", "example_key", flutterEnvStaging.getProperty('EXAMPLE_KEY')
            applicationIdSuffix ".stg"
            manifestPlaceholders = [appName: "[STG] Starting Flutter Project"]
        }
    }
```

Then you can use that value inside `MainActivity.kt` like that:

```kotlin
package com.lilatee.startingproject.starting_flutter_project

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val exampleKey: String = getString(R.string.example_key)
    }
}
```

# Golden - Screenshot Tests
Project uses [golden_test](https://pub.dev/packages/golden_test) package for golden test and [golden_toolkig](https://pub.dev/packages/golden_toolkit) for fixing fonts and icons on screenshots.

1. Add package to `dev_dependencies`. For now there is an opened PR that adds support for Routers.

```yaml
dev_dependencies:
  golden_test:
    git: 
      url: https://github.com/dmkasperski/golden_test
      ref: add_support_for_router
```

2. Copy `test/helpers/golden_test_runner.dart` file. It's a function that is used to run every golden test. It handles default state of every golden test.

3. Copy `test/flutter_test_config.dart` file. It has some basic stuff that is used in every test. Here we use [golden_toolkit](https://pub.dev/packages/golden_toolkit) package for fixing fonts and icons on screenshots.

4. Add configuration in `.vscode/launch.json` to run test from test files directly. 

```yaml
{
  "configurations": [
    {
      "name": "Goldens",
      "request": "launch",
      "type": "dart",
      "codeLens": {
        "for": [
          "run-test",
          "run-test-file"
        ]
      },
      "args": [
        "--update-goldens"
      ]
    },
  ]
}
```

5. Add new rules to gitignore in the main directory of the project

```
# Golden tests failures
**/failures/**.png
```

In VS Code you should see `Goldens` button above `runGoldenTest` function.
![goldens_button](readme_resources/goldens_button.png)

# Linter
Project uses mostly [leancode_lint](https://pub.dev/packages/leancode_lint) with some minor changes.

Add a required packages
```bash
dart pub add leancode_lint custom_lint --dev
```

and create `analysis_options.yaml` file in the root of the project

# Githooks

In order to enable githooks in the following configuration remember to run

```shell
git config core.hooksPath .githooks 
```

### pre-commit
Uses `dart format` command to format all files to a proper format with a line length equals to 120. It uses rules defined in `analysis_options.yaml` file.

File is present in `.githooks/pre-commit`.

### pre-push
Runs:
- `./tools/dart_analysis.sh` script,
- `flutter test test` command to run tests inside `test` directory;

`dart_analysis.sh` script uses [dart_code_linter](https://pub.dev/packages/dart_code_linter) for finding for unused parts of the codes and [custom_lint](https://pub.dev/packages/custom_lint) for running custom lints so please remmeber to add both of these packages:

```shell
dart pub add --dev dart_code_linter custom_lint
```

Files are present in `.githooks/pre-push` and `tools/dart_analysis.sh`.

# Helpful scripts

- `tools/fix_flutter_environment.sh` - Script for removing everything (I hope so) related to Flutter. Run it if something does not work and maybe it will fix it.

# Github Workflows

`.github/workflows` stores common versions of tools for every workflow in order to be consistent with the version of tools across different workflows.

In order to run tests on CI we have to provide a placeholder values for our environments variables. For that case please remember to fill `defaultValue` parameter when adding a new field in `/lib/core/envs/env.dart` file.

e.g
```dart
  @EnviedField(defaultValue: 'example_key_development', varName: 'EXAMPLE_KEY', obfuscate: true)
  static final String key = _Env.key;
```

## Test and Analyze workflow
File: `.github/workflows`

Responsible for running `./tools/dart_analysis.sh` script and `flutter test` command.

For now [golden_test](https://pub.dev/packages/golden_test) package does not support CI tests by handling problems with differnt rendering depending on system. So here you have to use the same system that you use locally. If it will be a big issue you should consider using [alchemist](https://pub.dev/packages/alchemist) which solves that problem.

If any test fails then you can find `goldens` artifact on Github which stores information what exactly tests failed and what are the differences.

![goldens_artifact](readme_resources/goldens_artifact.png)

# Getting Started 🚀

This project contains 3 flavors:

- development
- staging
- production

To run the desired flavor either use the launch configuration in VSCode/Android Studio or use the following commands:

```sh
# Development
$ flutter run --flavor development --target lib/main_development.dart

# Staging
$ flutter run --flavor staging --target lib/main_staging.dart

# Production
$ flutter run --flavor production --target lib/main_production.dart
```

_\*Starting Flutter Project works on iOS, Android, Web, and Windows._

---

# Running Tests 🧪

To run all unit and widget tests use the following command:

```sh
$ flutter test --coverage --test-randomize-ordering-seed random
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
$ genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
$ open coverage/index.html
```

---

# Working with Translations 🌐

This project relies on [flutter_localizations][flutter_localizations_link] and follows the [official internationalization guide for Flutter][internationalization_link].

## Adding Strings

1. To add a new localizable string, open the `app_en.arb` file at `lib/l10n/arb/app_en.arb`.

```arb
{
    "@@locale": "en",
    "counterAppBarTitle": "Counter",
    "@counterAppBarTitle": {
        "description": "Text shown in the AppBar of the Counter Page"
    }
}
```

2. Then add a new key/value and description

```arb
{
    "@@locale": "en",
    "counterAppBarTitle": "Counter",
    "@counterAppBarTitle": {
        "description": "Text shown in the AppBar of the Counter Page"
    },
    "helloWorld": "Hello World",
    "@helloWorld": {
        "description": "Hello World Text"
    }
}
```

3. Use the new string

```dart
import 'package:starting_flutter_project/l10n/l10n.dart';

@override
Widget build(BuildContext context) {
  final l10n = context.l10n;
  return Text(l10n.helloWorld);
}
```

## Adding Supported Locales

Update the `CFBundleLocalizations` array in the `Info.plist` at `ios/Runner/Info.plist` to include the new locale.

```xml
    ...

    <key>CFBundleLocalizations</key>
	<array>
		<string>en</string>
		<string>es</string>
	</array>

    ...
```

## Adding Translations

1. For each supported locale, add a new ARB file in `lib/l10n/arb`.

```
├── l10n
│   ├── arb
│   │   ├── app_en.arb
│   │   └── app_es.arb
```

2. Add the translated strings to each `.arb` file:

`app_en.arb`

```arb
{
    "@@locale": "en",
    "counterAppBarTitle": "Counter",
    "@counterAppBarTitle": {
        "description": "Text shown in the AppBar of the Counter Page"
    }
}
```

`app_es.arb`

```arb
{
    "@@locale": "es",
    "counterAppBarTitle": "Contador",
    "@counterAppBarTitle": {
        "description": "Texto mostrado en la AppBar de la página del contador"
    }
}
```

## Generating Translations

To use the latest translations changes, you will need to generate them:

1. Generate localizations for the current project:

```sh
flutter gen-l10n --arb-dir="lib/l10n/arb"
```

Alternatively, run `flutter run` and code generation will take place automatically.


# TODO LIST
- ✅ localization
- ✅ secrets
- ✅ golden tests - change local path to remote after merging to master
- upload dsym files
- releasing on Firebase
- Firebase crashylitcs
- Firebase analytics - logScreenViews
- releasing on TestFlight
- releasing on Google Internal Test
- ✅ flavors production, development, staging
- ✅ workflow tests, analyzer
- ✅ git hooks
- ✅ linter rules
- ✅ launch.json
- ✅ mise configuration
- ✅ dependabot
- CI info about missing translations

[coverage_badge]: coverage_badge.svg
[flutter_localizations_link]: https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html
[internationalization_link]: https://flutter.dev/docs/development/accessibility-and-localization/internationalization
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli

