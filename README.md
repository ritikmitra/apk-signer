# Sign Android APK

A Docker-based GitHub Action to sign Android APKs using a keystore.  
Supports choosing the Android Command-line tools version.

## Inputs

- `apk-path` (required) – Path to the APK to sign
- `keystore-base64` (required) – Base64-encoded keystore file
- `keystore-password` (required) – Keystore password
- `key-alias` (required) – Key alias
- `key-password` (required) – Key password
- `sdk-version` (optional, default `12.0`) – Command-line tools version (short version, e.g., 12.0)
- `build-tools-version` (optional, default `33.0.2`) – Build tools version (e.g., 33.0.2)

Supported versions:

| Short version | Internal revision |
|---------------|-----------------|
| 20.0          | 14742923        |
| 16.0          | 12266719        |
| 13.0          | 11479570        |
| 12.0          | 11076708        |
| 11.0          | 10406996        |
| 10.0          | 9862592         |
| 9.0           | 9477386         |
| 8.0           | 9123335         |
| 7.0           | 8512546         |

## Example workflow

```yaml
name: Sign APK
on: [push]

jobs:
  sign:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - name: Sign APK
        uses: ritikmitra/apk-signer@v1
        with:
          apk-path: app/build/outputs/apk/release/app-release-unsigned.apk
          keystore-base64: ${{ secrets.KEYSTORE_BASE64 }}
          keystore-password: ${{ secrets.KEYSTORE_PASSWORD }}
          key-alias: ${{ secrets.KEY_ALIAS }}
          key-password: ${{ secrets.KEY_PASSWORD }}
          sdk-version: "12.0"
          build-tools-version : "33.0.2"