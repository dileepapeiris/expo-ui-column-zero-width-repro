#!/bin/sh
# Copies the fixed Swift files from an expo checkout on the fix branch into this project's
# @expo/ui, and makes autolinking build ExpoUI from source instead of the precompiled module.
#   scripts/apply-fix.sh <path to expo checkout on fix/ui-ios-unsized-stack-cross-size>
# Then: cd ios && pod install && cd .. && npx expo run:ios
set -e
EXPO=$1
for f in UniversalLayout.swift SpacerView.swift UIBaseView.swift; do
  cp "$EXPO/packages/expo-ui/ios/$f" "node_modules/@expo/ui/ios/$f"
done
node -e '
const fs = require("fs");
const p = JSON.parse(fs.readFileSync("package.json"));
p.expo = { ...(p.expo || {}), autolinking: { ...((p.expo || {}).autolinking || {}), buildFromSource: ["ExpoUI"] } };
fs.writeFileSync("package.json", JSON.stringify(p, null, 2) + "\n");
'
echo "fix applied; ExpoUI will build from source"
