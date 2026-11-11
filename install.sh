#!/data/data/com.termux/files/usr/bin/bash
# Installs the newest TV Home build on the Mi Box and makes it the home screen.
# Usage:  ./install.sh            (uses the default IP below)
#         ./install.sh 10.21.2.31
set -e
BOX="${1:-10.21.2.31}:5555"
REPO="Tetan1234/tvos-home"
APK="$HOME/tvos-home.apk"

echo "Downloading latest build..."
curl -fL -o "$APK" "https://github.com/$REPO/releases/latest/download/tvos-home.apk"

echo "Connecting to $BOX..."
adb connect "$BOX" >/dev/null
adb -s "$BOX" wait-for-device

echo "Installing..."
adb -s "$BOX" install -r "$APK"

echo "Allowing the Ad block button..."
adb -s "$BOX" shell pm grant com.tetan.tvos android.permission.WRITE_SECURE_SETTINGS

echo "Setting as home screen..."
adb -s "$BOX" shell cmd package set-home-activity com.tetan.tvos/.HomeActivity
adb -s "$BOX" shell input keyevent KEYCODE_HOME

echo "Done. Press HOME on the remote."
