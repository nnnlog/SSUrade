# SSUrade
* 숭실대학교 학사 정보 조회 애플리케이션

## 설치
* [Play Store](https://play.google.com/store/apps/details?id=com.nnnlog.ssurade)
* 곧 iOS 지원을 시작합니다.
* [Github Release](https://github.com/nnnlog/ssurade/releases)

## 사용법
* Read [Usage.md](./USAGE.md)

## 빌드 방법

### 1. 웹뷰에 삽입할 자바스크립트 코드를 빌드합니다.
* 요구 사항: Node.js, npm
```shell
cd usaint-injector/
npm ci
npm run build
mkdir ../assets/js/
cp dist/main.js ../assets/js/common.js
```

### 2. 플러터 디펜던시를 설치합니다.
* 요구 사항: Flutter
```shell
flutter pub get
```

## 3. 프로젝트 설정
### iOS 빌드
* iOS 빌드를 위해서 macOS에 xcode를 설치해야 합니다. 또한, xcode에서 적절한 설정(개발자 프로필 설정 등)이 필요합니다.
* TBD

### Android 빌드
* 소유하고 있는 `key.properties`를 `android/` 디렉토리에 넣어주세요. (apk를 서명하는 데 사용합니다.)
* 만약 `key.properties`를 소유하고 있지 않다면, 자동 생성된 `android/local.properties`를 복사해서 사용할 수 있습니다. (해당 파일은 자동 생성되는 디버깅용 키로써, 배포용으로는 적합하지 않습니다.)

### 3. 빌드
* 요구 사항: Flutter
```shell
flutter build ios --obfuscate --split-debug-info=./debug/
flutter build ipa --obfuscate --split-debug-info=./debug/
flutter build apk --obfuscate --split-debug-info=./debug/
flutter build appbundle --obfuscate --split-debug-info=./debug/
```

### 4. 빌드 후
#### (선택/프로덕션 전용) Sentry에 디버깅 심볼 업로드 방법
```shell
SENTRY_AUTH_TOKEN=<token> SENTRY_ORG=<org> SENTRY_PROJECT=<project name> flutter packages pub run sentry_dart_plugin
```

#### Play Console에서 사용되는 네이티브 디버그 심볼 위치
* `build/app/intermediates/merged_native_libs/release/out/lib/` 에서 찾을 수 있습니다.

## 개발 가이드
* SSUrade는 여려분의 기여를 환영합니다!
* PRD와 Tech Spec은 [Notion 문서](https://nnnlog.notion.site/SSUrade-Document-102cdd9e958680b58c59f6f80d6b9292?pvs=74)에서 확인할 수 있습니다.

### 프로젝트 구조
* TBD

### 자동 생성되는 코드
* SSUrade는 JSON Serailization, Injectable 등을 사용하고 있습니다.
* 해당 어노테이션이 있는 파일을 수정한 경우, 다음 명령어를 실행하여 코드를 자동으로 생성하세요.
```shell
dart run build_runner build
```

#### Setup Analytics (Firebase)
```shell
flutterfire configure --project=<Firbase project id>
```
