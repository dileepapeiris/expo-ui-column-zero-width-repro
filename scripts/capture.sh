#!/bin/sh
# Cold-starts the app on a simulator, records 11 s of screen, and takes a screenshot of each case.
#   scripts/capture.sh <simulator udid> <output prefix>      e.g. scripts/capture.sh 9C09... media/before
# Metro must be running (npx expo start) and the app installed (npx expo run:ios).
UDID=$1; OUT=$2; APP=dev.dileepapeiris.columnzerowidthrepro
xcrun simctl terminate "$UDID" $APP 2>/dev/null
xcrun simctl io "$UDID" recordVideo --codec h264 --force "$OUT.mp4" &
REC=$!
sleep 1
xcrun simctl launch "$UDID" $APP >/dev/null
sleep 3.5; xcrun simctl io "$UDID" screenshot "$OUT-list.png" >/dev/null
sleep 5;   xcrun simctl io "$UDID" screenshot "$OUT-spacer.png" >/dev/null
sleep 1.5; kill -INT $REC; wait $REC 2>/dev/null
echo "wrote $OUT.mp4 $OUT-list.png $OUT-spacer.png"
