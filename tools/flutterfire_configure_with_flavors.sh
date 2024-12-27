#!/bin/bash
# Script to generate Firebase configuration files for different environments/flavors
# Feel free to reuse and adapt this script for your own projects

# The name of created project on Firebase. It has to be created manually.
# https://console.firebase.google.com/
projectName=starting-flutter-project
iosPackageName=com.lilatee.starting-flutter-project
androidPackageName=com.lilatee.starting_flutter_project


if [[ $# -eq 0 ]]; then
  echo "Error: No environment specified. Use 'dev', 'stg', or 'prod'."
  exit 1
fi

case $1 in
  dev)
    flutterfire config \
      --project=$projectName-dev \
      --out=lib/firebase_options_dev.dart \
      --ios-bundle-id=$iosPackageName.dev \
      --ios-out=ios/flavors/development/GoogleService-Info.plist \
      --android-package-name=$androidPackageName.dev \
      --android-out=android/app/src/development/google-services.json
    ;;
  stg)
    flutterfire config \
      --project=$projectName-stg \
      --out=lib/firebase_options_stg.dart \
      --ios-bundle-id=$iosPackageName.stg \
      --ios-out=ios/flavors/staging/GoogleService-Info.plist \
      --android-package-name=$androidPackageName.stg \
      --android-out=android/app/src/staging/google-services.json
    ;;
  prod)
    flutterfire config \
      --project=$projectName-prod \
      --out=lib/firebase_options_prod.dart \
      --ios-bundle-id=$iosPackageName \
      --ios-out=ios/flavors/production/GoogleService-Info.plist \
      --android-package-name=$androidPackageName \
      --android-out=android/app/src/production/google-services.json
    ;;
  *)
    echo "Error: Invalid environment specified. Use 'dev', 'stg', or 'prod'."
    exit 1
    ;;
esac