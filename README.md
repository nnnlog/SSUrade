# ssurade
SSUrade : 숭실대학교 학점 조회 애플리케이션

## Installation
* [Play Store](https://play.google.com/store/apps/details?id=com.nnnlog.ssurade)
* [Github Release](https://github.com/nnnlog/ssurade/releases)

## Build
### Set signing key
* Put your key file as `key/nlog.jks`

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

### Build for Android
```shell
flutter pub run build_runner build
flutter build apk
```