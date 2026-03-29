#!/bin/bash
set -e

APK_PATH="$1"
KEYSTORE_BASE64="$2"
KEYSTORE_PASSWORD="$3"
KEY_ALIAS="$4"
KEY_PASSWORD="$5"
SDK_SHORT_VERSION="${6:-12.0}"

# Version table: Short version -> internal revision
declare -A sdk_versions
sdk_versions=(
  ["20.0"]="14742923"
  ["16.0"]="12266719"
  ["13.0"]="11479570"
  ["12.0"]="11076708"
  ["11.0"]="10406996"
  ["10.0"]="9862592"
  ["9.0"]="9477386"
  ["8.0"]="9123335"
  ["7.0"]="8512546"
)

SDK_REVISION=${sdk_versions[$SDK_SHORT_VERSION]}

if [ -z "$SDK_REVISION" ]; then
  echo "Error: Unknown SDK version $SDK_SHORT_VERSION"
  exit 1
fi

SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-${SDK_REVISION}_latest.zip"

echo "Downloading Android SDK $SDK_SHORT_VERSION (revision $SDK_REVISION)..."
wget -q $SDK_URL -O cmdline-tools.zip
mkdir -p /sdk/cmdline-tools
unzip -q cmdline-tools.zip -d /sdk/cmdline-tools
rm cmdline-tools.zip

export PATH=$PATH:/sdk/cmdline-tools/tools/bin

# Decode keystore
echo "$KEYSTORE_BASE64" | base64 --decode > keystore.jks

# Align APK
zipalign -v -p 4 "$APK_PATH" aligned.apk

# Sign APK
apksigner sign --ks keystore.jks \
               --ks-pass pass:$KEYSTORE_PASSWORD \
               --key-pass pass:$KEY_PASSWORD \
               --out signed.apk aligned.apk

echo "APK signed successfully: signed.apk"