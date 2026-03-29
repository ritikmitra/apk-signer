#!/bin/bash
set -euo pipefail

echo "Starting APK signing process..."

APK_PATH="$1"
KEYSTORE_BASE64="$2"
KEYSTORE_PASSWORD="$3"
KEY_ALIAS="$4"
KEY_PASSWORD="$5"
SDK_SHORT_VERSION="${6:-12.0}"

# ... your existing version table code ...

echo "Downloading SDK version $SDK_SHORT_VERSION..."

wget -q "$SDK_URL" -O cmdline-tools.zip || { echo "Failed to download SDK"; exit 1; }
mkdir -p /sdk/cmdline-tools
unzip -q cmdline-tools.zip -d /sdk/cmdline-tools || { echo "Failed to unzip SDK"; exit 1; }
rm cmdline-tools.zip

export PATH=$PATH:/sdk/cmdline-tools/tools/bin

echo "Decoding keystore..."
echo "$KEYSTORE_BASE64" | base64 --decode > keystore.jks || { echo "Failed to decode keystore"; exit 1; }

echo "Aligning APK..."
zipalign -v -p 4 "$APK_PATH" aligned.apk || { echo "zipalign failed"; exit 1; }

echo "Signing APK..."
apksigner sign --ks keystore.jks \
               --ks-pass pass:"$KEYSTORE_PASSWORD" \
               --key-pass pass:"$KEY_PASSWORD" \
               --out signed.apk aligned.apk || { echo "apksigner failed"; exit 1; }

echo "Verifying signed APK..."
apksigner verify signed.apk || { echo "Verification failed"; exit 1; }

echo "APK signed successfully!"

exit 0