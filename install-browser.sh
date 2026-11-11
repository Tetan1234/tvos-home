#!/data/data/com.termux/files/usr/bin/bash
# Installs a web browser on the Mi Box (32-bit ARM, Android 9).
#
#   ./install-browser.sh tvbro      TV Bro  - made for the remote, has its own ad blocker (default)
#   ./install-browser.sh firefox    Firefox - real Firefox, can use uBlock Origin,
#                                   but it's a phone app: best with a mouse or air-mouse remote
#
# Optional 2nd argument: the box's IP (default 10.21.2.31)
set -e
WHICH="${1:-tvbro}"
BOX="${2:-10.21.2.31}:5555"
APK="$HOME/browser.apk"

case "$WHICH" in
  tvbro)
    echo "Finding the latest TV Bro release..."
    LIST=$(curl -fsSL https://api.github.com/repos/truefedex/tv-bro/releases/latest \
           | grep -o '"browser_download_url": *"[^"]*\.apk"' | sed 's/.*"\(https[^"]*\)"/\1/')
    # the box is 32-bit ARM: prefer an armeabi-v7a / generic / universal build
    URL=$(echo "$LIST" | grep -iE 'armeabi|armv7|v7a|generic|universal' | grep -viE 'arm64|x86' | head -1)
    [ -z "$URL" ] && URL=$(echo "$LIST" | grep -viE 'arm64|x86' | head -1)
    ;;
  firefox)
    echo "Finding the latest Firefox release..."
    VER=$(curl -fsSL https://archive.mozilla.org/pub/fenix/releases/ \
          | grep -oE 'releases/[0-9]+\.[0-9]+(\.[0-9]+)?/' | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' \
          | sort -V | tail -1)
    URL="https://archive.mozilla.org/pub/fenix/releases/$VER/android/fenix-$VER-android-armeabi-v7a/fenix-$VER.multi.android-armeabi-v7a.apk"
    ;;
  *)
    echo "Use: ./install-browser.sh tvbro   or   ./install-browser.sh firefox"; exit 1 ;;
esac

if [ -z "$URL" ]; then
  echo "Couldn't find a 32-bit APK. Files in the latest release were:"; echo "$LIST"; exit 1
fi

echo "Downloading $URL"
curl -fL -o "$APK" "$URL"

adb connect "$BOX" >/dev/null
adb -s "$BOX" wait-for-device
echo "Installing..."
adb -s "$BOX" install -r "$APK"
rm -f "$APK"
echo "Done. On the TV: All apps -> hold OK on the browser -> Add to dock."
