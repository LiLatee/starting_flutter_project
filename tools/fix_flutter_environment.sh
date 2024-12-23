#!/bin/bash
# Script for removing everything (I hope so) related to Flutter.
# Run it if something does not work and maybe it will fix it.

# Navigates to the root directory of the project.
# In that case to the directory with the name of the Flutter project.
# So it can be run from anywhere.
parent_path=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
cd "$parent_path/.." || exit


android_studio=$(ps aux | grep -v grep | grep -ci '/studio')
visual_studio_code=$(ps aux | grep -v grep | grep -ci '/Applications/Visual Studio Code.app/Contents/Frameworks/Code')
x_code=$(ps aux | grep -v grep | grep -ci '/Contents/MacOS/Xcode')

if [ $android_studio -gt 0 ]; then
  echo Android Studio running, shut it down
  exit
fi

if [ $visual_studio_code -gt 0 ]; then
  echo Visual Studio Code running, shut it down
  exit
fi

if [ $x_code -gt 0 ]; then
  echo Xcode running, shut it down
  exit
fi

rm -r ~/.dartServer/.analysis-driver
dart pub cache clean -f
flutter clean
pod cache clean --all
flutter pub get
cd ios || exit ; pod install ; cd ..
flutter analyze