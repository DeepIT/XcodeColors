#!/bin/bash

# show Xcode version and UUID
xcodebuild -version
for xc in Xcode Xcode-beta; do
    app=/Applications/$xc.app
    if [[ -e $app ]]; then
        echo "Updating for $app"
        uuid=$(defaults read $app/Contents/Info DVTPlugInCompatibilityUUID)
        echo "UUID $uuid"
        echo ""

        # check UUID
        plist=$(pwd)/XcodeColors/Info.plist
        if [ -n "$(defaults read "$plist" | grep $uuid)" ] ; then
            echo "UUID is already added to $plist"
            continue
        fi

        # add UUID to .plist
        echo "Add UUID to $plist"
        defaults write "$plist" DVTPlugInCompatibilityUUIDs -array-add $uuid
    fi
done

# The defaults tool will write a binary plist
# Convert it back to XML to make the diff's readable
plutil -convert xml1 "$plist"

# show the result
defaults read "$plist"
