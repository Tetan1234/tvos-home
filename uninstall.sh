#!/data/data/com.termux/files/usr/bin/bash
# Removes TV Home. The box goes back to your previous home screen
# (if it asks which one, pick it and choose "Always").
BOX="${1:-10.21.2.31}:5555"
adb connect "$BOX" >/dev/null
adb -s "$BOX" uninstall com.tetan.tvos
adb -s "$BOX" shell input keyevent KEYCODE_HOME
