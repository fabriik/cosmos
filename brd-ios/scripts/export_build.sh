#!/bin/bash
archive_path="$PWD/build/"$scheme".xcarchive"
export_path="$PWD/build"
scheme="breadwallet"

# Export the build
xcodebuild -exportArchive -archivePath "$archive_path" -exportOptionsPlist $PWD/build/exportOptions.plist -exportPath $export_path
