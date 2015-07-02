#!/bin/bash

# show Xcode version and UUID
xcodebuild -version
uuid=$(defaults read /Applications/Xcode.app/Contents/Info DVTPlugInCompatibilityUUID)
echo "UUID $uuid"
echo ""

# check UUID
plist=$(pwd)/XcodeColors/Info.plist
if [ -n "$(defaults read '$plist' | grep $uuid)" ] ; then
    echo "UUID is already added to Info.plist"
    exit
fi

# add UUID to .plist
echo "Add UUID to '$plist'"
defaults write '$plist' DVTPlugInCompatibilityUUIDs -array-add $uuid

# show the result
defaults read '$plist'
