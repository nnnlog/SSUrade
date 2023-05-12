# ssurade
SSUrade : 숭실대학교 성적/학점 조회 애플리케이션

## Installation
* [Play Store](https://play.google.com/store/apps/details?id=com.nnnlog.ssurade)
* [Github Release](https://github.com/nnnlog/ssurade/releases)

## Build Instruction (for Android only)
### Set signing key
* Put your `key.properties` in `android/` directory.
* If you don't have your own `key.properties`, you can copy and paste of auto-generated `android/local.properties`.

### Analytics (Firebase)
#### Init
```shell
flutterfire configure --project=<Firbase project id>
```

#### Debug (Start)
```shell
adb shell setprop debug.firebase.analytics.app com.nnnlog.ssurade
```

#### Debug (End)
```shell
adb shell setprop debug.firebase.analytics.app .none.
```

### Build
```shell
flutter pub run build_runner build
flutter build apk
```