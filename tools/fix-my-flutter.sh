#!/bin/bash
# Script for removing everything (I hope so) related to Flutter.
# Run it if something does not work and maybe it will fix it.

# Makes all paths relative to project root so it can be run from anywhere
parent_path=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
cd "$parent_path/.." || exit

as=$(ps aux | grep -v grep | grep -ci '/studio')
vsc=$(ps aux | grep -v grep | grep -ci '/Applications/Visual Studio Code.app/Contents/Frameworks/Code')
xc=$(ps aux | grep -v grep | grep -ci '/Contents/MacOS/Xcode')

if [ $as -gt 0 ]; then
  echo Android Studio running, shut it down
  exit
fi

if [ $vsc -gt 0 ]; then
  echo Visual Studio Code running, shut it down
  exit
fi

if [ $xc -gt 0 ]; then
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