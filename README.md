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

### Configuration for other services
* You should create `.env` file in the root directory for setting up the environment variables.
* Now, Sentry and Firebase are supported. You should fill the `.env` file with below format.
* If you don't have the values, you can just leave it blank.
```
SENTRY_DSN=
SENTRY_TRACES_SAMPLE_RATE=

FIREBASE_ANDROID_API_KEY=
FIREBASE_ANDROID_APP_ID=
FIREBASE_ANDROID_MESSAGING_SENDER_ID=
FIREBASE_ANDROID_PROJECT_ID=
FIREBASE_ANDROID_STORAGE_BUCKET=

FIREBASE_IOS_API_KEY=
FIREBASE_IOS_APP_ID=
FIREBASE_IOS_MESSAGING_SENDER_ID=
FIREBASE_IOS_PROJECT_ID=
FIREBASE_IOS_STORAGE_BUCKET=
FIREBASE_IOS_IOS_BUNDLE_ID=
```

### 4. Build
```shell
flutter build ios --obfuscate --split-debug-info=./debug/ --dart-define-from-file=.env
flutter build ipa --obfuscate --split-debug-info=./debug/ --dart-define-from-file=.env
flutter build apk --obfuscate --split-debug-info=./debug/ --dart-define-from-file=.env
flutter build appbundle --obfuscate --split-debug-info=./debug/ --dart-define-from-file=.env
```
* `ios` means building iOS, `ipa` means that generated IPA file after building iOS, `apk` means building Android, and `appbundle` means building Android App Bundle.
* You should `ipa` or `appbundle` for deploying the application. (You must need Apple Developer account for building `ipa`)
* `--obfuscate` is the option for obfuscating the code. (optional)
* `--split-debug-info` is the option for splitting debug symbols. (optional)
* `--dart-define-from-file` is the option for reading environment variables from the file. (optional)
  * If you don't want to integrate with other services, you can just remove this option.

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

### Integrate with external services

#### Firebase (Analytics) Configuration
```shell
flutterfire configure --project=<Firebase project id>
```
* You should fill the your environment variable files based on the content of generated `lib/firebase_options.dart` file.
* You could find the schema of environment variable file in this README.

#### Sentry Initialization
* You could find the schema of environment variable file in this README.
* Supported Sentry Options in Environment variable file:
  * SENTRY_DSN
  * SENTRY_TRACES_SAMPLE_RATE (0 ~ 1, double)
