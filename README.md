# ssurade
SSUrade : 숭실대학교 성적/학점 조회 애플리케이션

## Installation
* [Play Store](https://play.google.com/store/apps/details?id=com.nnnlog.ssurade)
* [Github Release](https://github.com/nnnlog/ssurade/releases)

## Build Instruction (for Android only)
### Set signing key
* Put your `key.properties` in `android/` directory.
* If you don't have your own `key.properties`, you can copy and paste of auto-generated `android/local.properties`.

### Setup Analytics (Firebase)
```shell
flutterfire configure --project=<Firbase project id>
```

### Build Javascript code for injecting to WebView
```shell
cd usaint-injector/
npm ci
npm run build
mkdir ../assets/js/
cp dist/main.js ../assets/js/common.js
```

### Build
```shell
flutter pub run build_runner build
flutter build apk --obfuscate --split-debug-info=./debug/
flutter build appbundle --obfuscate --split-debug-info=./debug/
```

### (Optional) Upload debug symbols to Sentry
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
