#!/bin/bash
set -euo pipefail

APK_PATH="$1"
KEYSTORE_BASE64="$2"
KEYSTORE_PASSWORD="$3"
KEY_ALIAS="$4"
KEY_PASSWORD="$5"
SDK_SHORT_VERSION="${6:-12.0}"
BUILD_TOOLS_VERSION="${7:-33.0.2}"

# Version table
declare -A sdk_versions=(
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

SDK_REVISION=${sdk_versions[$SDK_SHORT_VERSION]:-}

if [ -z "$SDK_REVISION" ]; then
  echo "Error: Unknown SDK version $SDK_SHORT_VERSION"
  exit 1
fi

# Use consistent SDK location
export ANDROID_HOME="$HOME/Android/Sdk"
mkdir -p "$ANDROID_HOME"

SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-${SDK_REVISION}_latest.zip"

echo "Downloading Android SDK $SDK_SHORT_VERSION (revision $SDK_REVISION)..."
wget -q "$SDK_URL" -O cmdline-tools.zip

unzip -q cmdline-tools.zip -d "$ANDROID_HOME/cmdline-tools"
mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
rm cmdline-tools.zip

export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"

# Debug (optional)
echo "sdkmanager path:"
which sdkmanager || { echo "sdkmanager not found"; exit 1; }

# Accept licenses
yes | sdkmanager --licenses > /dev/null

# Install build-tools
echo "Installing build-tools version $BUILD_TOOLS_VERSION..."
sdkmanager "build-tools;$BUILD_TOOLS_VERSION"

# Add build-tools to PATH
export PATH="$PATH:$ANDROID_HOME/build-tools/$BUILD_TOOLS_VERSION"

echo "Decoding keystore..."
echo "$KEYSTORE_BASE64" | base64 --decode > keystore.jks

echo "Aligning APK..."
zipalign -v -p 4 "$APK_PATH" aligned.apk

echo "Signing APK..."
apksigner sign --ks keystore.jks \
               --ks-pass pass:"$KEYSTORE_PASSWORD" \
               --key-pass pass:"$KEY_PASSWORD" \
               --out signed.apk aligned.apk

echo "Verifying signed APK..."
apksigner verify signed.apk

echo "APK signed and verified successfully: signed.apk"

exit 0