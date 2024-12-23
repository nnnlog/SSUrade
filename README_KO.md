# SSUrade
* 숭실대학교 학사 정보 조회 애플리케이션

## 설치
* [Play Store](https://play.google.com/store/apps/details?id=com.nnnlog.ssurade)
* [App Store](https://apps.apple.com/app/id6720747785)
* [Github Release](https://github.com/nnnlog/ssurade/releases)

## 사용법
* [Usage.md](./USAGE.md)를 읽어주세요.

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
* 요구 사항: Flutter (Version : 3.27.0, 가능하다면 베타 채널을 따라감)
```shell
flutter pub get
```

## 3. 프로젝트 설정
### iOS 빌드
* iOS 빌드를 위해서 macOS에 xcode를 설치해야 합니다. 또한, xcode에서 적절한 설정(개발자 프로필 설정 등)이 필요합니다.

### Android 빌드
* 소유하고 있는 `key.properties`를 `android/` 디렉토리에 넣어주세요. (apk를 서명하는 데 사용합니다.)
* 만약 `key.properties`를 소유하고 있지 않다면, 자동 생성된 `android/local.properties`를 복사해서 사용할 수 있습니다. (해당 파일은 자동 생성되는 디버깅용 키로써, 배포용으로는 적합하지 않습니다.)

### 다른 서비스 설정
* 환경 변수를 설정하기 위해 루트 디렉토리에 `.env` 파일을 생성해주세요.
* 현재 Sentry와 Firebase를 지원하고 있습니다. `.env` 파일을 아래와 같은 형식으로 채워주세요.
* 값이 없다면 빈칸으로 두셔도 됩니다.
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

### 4. 빌드
* 요구 사항: Flutter
```shell
flutter build ios --obfuscate --split-debug-info=./debug/ --dart-define-from-file=.env
flutter build ipa --obfuscate --split-debug-info=./debug/ --dart-define-from-file=.env
flutter build apk --obfuscate --split-debug-info=./debug/ --dart-define-from-file=.env
flutter build appbundle --obfuscate --split-debug-info=./debug/ --dart-define-from-file=.env
```
* `ios`는 iOS 빌드, `ipa`는 iOS 빌드 후 IPA 파일 생성, `apk`는 Android 빌드, `appbundle`은 Android App Bundle 빌드입니다.
* 앱 배포를 위해서는 `ipa` 또는 `appbundle`을 사용하세요. (`ipa` 빌드를 위해서는 Apple Developer 계정이 필요합니다.)
* `--obfuscate` 옵션은 코드 난독화를 위한 옵션입니다. (선택 사항)
* `--split-debug-info` 옵션은 디버그 심볼을 분리하는 옵션입니다. (선택 사항)
* `--dart-define-from-file` 옵션은 `.env` 파일을 읽어서 환경 변수를 설정하는 옵션입니다.
  * 다른 서비스와 연동하지 않으려면 이 옵션을 사용하지 않아도 됩니다.

### 5. 빌드 후
#### (선택/프로덕션 전용) Sentry에 디버깅 심볼 업로드 방법
```shell
SENTRY_AUTH_TOKEN=<token> SENTRY_ORG=<org> SENTRY_PROJECT=<project name> flutter packages pub run sentry_dart_plugin
```

#### Play Console에서 사용되는 네이티브 디버그 심볼 위치
* `build/app/intermediates/merged_native_libs/release/mergeReleaseNativeLibs/out/lib/` 에서 찾을 수 있습니다.

## 개발 가이드 및 프로젝트 구조
* SSUrade는 여려분의 기여를 환영합니다!
* PRD와 Tech Spec은 [SSUrade 문서](https://ssurade.nlog.dev)에서 확인할 수 있습니다.

### 자동 생성되는 코드
* SSUrade는 JSON Serialization, Injectable, Auto Exporter 등을 사용하고 있습니다.
* 해당 어노테이션이 있는 파일을 수정한 경우, 프로젝트 루트 디렉터리에서 다음 명령어를 실행하여 코드를 자동으로 생성하세요.
```shell
./scripts/gen.sh
```

### 코드 포맷팅
```shell
./scripts/format.sh
```

### 외부 서비스 연동

#### Firebase (Analytics) 설정
```shell
flutterfire configure --project=<Firebase project id>
```
* 생성된 `lib/firebase_options.dart` 파일의 내용을 기반으로 환경 변수 파일을 채워주세요.
* 이 README의 환경 변수 파일 스키마를 참고하세요.

#### Sentry 설정
* 이 README의 환경 파일 스키마를 참고하세요.
* 환경 변수 파일에서 지원하는 Sentry 설정은 다음과 같습니다.
  * SENTRY_DSN
  * SENTRY_TRACES_SAMPLE_RATE (0 ~ 1, double)
