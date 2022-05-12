#!/bin/zsh

FRAMEWORK_PATH="${PWD%/*/*}/cosmos-bundled/build-frameworks/Cosmos.xcframework"
FRAMEWORK_BIN_PATH="$FRAMEWORK_PATH/ios-arm64-simulator/Cosmos.framework/Cosmos"
FRAMEWORK_PATH_PLIST="$FRAMEWORK_PATH/Info.plist"
FRAMEWORK_PATH_ARM_PLIST="$FRAMEWORK_PATH/ios-arm64-simulator/Cosmos.framework/Info.plist"

cp -r "$FRAMEWORK_PATH/ios-arm64" "$FRAMEWORK_PATH/ios-arm64-simulator"

xcrun vtool -arch arm64 \
            -set-build-version 7 12.0 12.0 \
            -replace \
            -output "$FRAMEWORK_BIN_PATH.updated" \
            $FRAMEWORK_BIN_PATH

rm $FRAMEWORK_BIN_PATH
mv "$FRAMEWORK_BIN_PATH.updated" $FRAMEWORK_BIN_PATH

plistBuddy="/usr/libexec/PlistBuddy"

x86Idx=""

if [[ $($plistBuddy -c "Print :AvailableLibraries:0:LibraryIdentifier" "$FRAMEWORK_PATH_PLIST") == "ios-x86_64-simulator" ]]; then
  x86Idx="0"
fi

if [[ $($plistBuddy -c "Print :AvailableLibraries:1:LibraryIdentifier" "$FRAMEWORK_PATH_PLIST") == "ios-x86_64-simulator" ]]; then
  x86Idx="1"
fi

if [[ $x86Idx == "" ]]; then
  echo "Could not find ios-x86_64-simulator LibraryIdentifier in $FRAMEWORK_PATH_PLIST"
  exit
fi

$plistBuddy -c "Set :CFBundleSupportedPlatforms:0 iPhoneSimulator" "$FRAMEWORK_PATH_ARM_PLIST"
$plistBuddy -c "Set :AvailableLibraries:$x86Idx:SupportedArchitectures:0 arm64" "$FRAMEWORK_PATH_PLIST"
$plistBuddy -c "Set :AvailableLibraries:$x86Idx:LibraryIdentifier ios-arm64-simulator" "$FRAMEWORK_PATH_PLIST"
$plistBuddy -c "Set :AvailableLibraries:$x86Idx:SupportedPlatformVariant simulator" "$FRAMEWORK_PATH_PLIST"

xcrun codesign --sign - $FRAMEWORK_BIN_PATH
