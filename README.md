# SSUrade
SSUrade : Soongsil University Information Inquiry Application
* 숭실대학교 학사 정보 조회 애플리케이션

## Installation
* [Play Store](https://play.google.com/store/apps/details?id=com.nnnlog.ssurade)
* 곧 iOS 지원을 시작합니다!
* [Github Release](https://github.com/nnnlog/ssurade/releases)

## Usage
* Read [Usage.md](./USAGE.md)

## Build Instruction

### 1. Build Javascript code for injecting to WebView
```shell
cd usaint-injector/
npm ci
npm run build
mkdir ../assets/js/
cp dist/main.js ../assets/js/common.js
```

### 2. Install dependency
```shell
flutter pub get
```

### 3. Build
* For iOS build, you should install xcode in macOS. Also, please set appropriate settings in your xcode.
```shell
flutter build ios --obfuscate --split-debug-info=./debug/
flutter build apk --obfuscate --split-debug-info=./debug/
flutter build appbundle --obfuscate --split-debug-info=./debug/
```

### (Optional/Production) Upload debug symbols to Sentry
```shell
SENTRY_AUTH_TOKEN=<token> SENTRY_ORG=<org> SENTRY_PROJECT=<project name> flutter packages pub run sentry_dart_plugin
```

### Native Debug Symbols Location (used in Play Console)
* Found in `build/app/intermediates/merged_native_libs/release/out/lib/`

## Debug using Analytics (Firebase)
### Debug (Start)
```shell
adb shell setprop debug.firebase.analytics.app com.nnnlog.ssurade
```

### Debug (End)
```shell
adb shell setprop debug.firebase.analytics.app .none.
```

## Project Setup (for developers)
### Build for iOS
* For building iOS artifacts, you must need macOS and install xcode in your computer.

### Set signing key for Android
* Put your `key.properties` in `android/` directory.
* If you don't have your own `key.properties`, you can copy and paste of auto-generated `android/local.properties`.

### Setup Analytics (Firebase)
```shell
flutterfire configure --project=<Firbase project id>
```

### Create auto-generated code
* If you modify code included @JSONSerializable annotation, you must run a below command.
```shell
flutter pub run build_runner build
```