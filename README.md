# SSUrade
* [README written in Korean / 한국어 README](./README_KO.md)
* Inquiry personal information for Soongsil Unversity

## Installation
* [Play Store](https://play.google.com/store/apps/details?id=com.nnnlog.ssurade)
* [App Store](https://apps.apple.com/app/id6720747785)
* [Github Release](https://github.com/nnnlog/ssurade/releases)

## Usage
* [Usage.md](./USAGE.md)

## Build Instruction

### 1. Build Javascript code injected into webview.
* Requirements: Node.js, npm
```shell
cd usaint-injector/
npm ci
npm run build
mkdir ../assets/js/
cp dist/main.js ../assets/js/common.js
```

### 2. Install flutter dependency
* Requirements: Flutter (Version : 3.27.0, following beta channel if possible)
```shell
flutter pub get
```

## 3. Project setting
### For iOS Build
* Install xcode in macOS for building iOS. Also, need to appropriate setting such as developer profile, etc.

### For Android Build
* Put your `key.properties` into `android/` directory, which is used for signing the apk.
* If you don't have own `key.properties`, you can copy auto-generated `android/local.properties`. *Note that it is not suitable for deployment.*

### 4. Build
```shell
flutter build ios --obfuscate --split-debug-info=./debug/
flutter build ipa --obfuscate --split-debug-info=./debug/
flutter build apk --obfuscate --split-debug-info=./debug/
flutter build appbundle --obfuscate --split-debug-info=./debug/
```
* `ios` means building iOS, `ipa` means that generated IPA file after building iOS, `apk` means building Android, and `appbundle` means building Android App Bundle.
* You should `ipa` or `appbundle` for deploying the application. (You must need Apple Developer account for building `ipa`)
* `--obfuscate` is the option for obfuscating the code. (optional)
* `--split-debug-info` is the option for splitting debug symbols. (optional)

### 5. After build
#### (Optional / For production only) Uploading sentry to debug symbols
```shell
SENTRY_AUTH_TOKEN=<token> SENTRY_ORG=<org> SENTRY_PROJECT=<project name> flutter packages pub run sentry_dart_plugin
```

#### Native debug symbols used in Play Console
* You could find in `build/app/intermediates/merged_native_libs/release/mergeReleaseNativeLibs/out/lib/`.

## (WIP / Only Korean) Contribution guide and Project structure
* SSUrade welcomes your contribution!
* PRD and Tech Spec could be found in [SSUrade Document](https://ssurade.nlog.dev).

### Auto-generated codes
* SSUrade uses JSON Serialization, Injectable, Auto Exporter, etc.
* If you edit files which have above annotations, you can generate the code with below command in project root directory.
```shell
./scripts/gen.sh
```

### Format codes
```shell
./scripts/format.sh
```

### Connect with external services

#### Firebase (Analytics) Initialization
```shell
flutterfire configure --project=<Firebase project id>
```

#### Sentry Initialization
* TBD
