# ssurade
SSUrade : 숭실대학교 학점 조회 애플리케이션

## Build
```shell
flutter pub run build_runner build
flutter build apk
```

### Analytics
#### Init
```shell
flutterfire configure --project=<Firbase project name>
```

#### Debug (Start)
```shell
adb shell setprop debug.firebase.analytics.app com.nnnlog.ssurade
```

#### Debug (End)
```shell
adb shell setprop debug.firebase.analytics.app .none.
```