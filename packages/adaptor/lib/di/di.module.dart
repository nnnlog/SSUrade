//@GeneratedMicroModule;SsuradeAdaptorPackageModule;package:ssurade_adaptor/di/di.module.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:injectable/injectable.dart' as _i526;
import 'package:ssurade_adaptor/crawling/service/external_absent_application_retrieval_service.dart'
    as _i507;
import 'package:ssurade_adaptor/crawling/service/external_chapel_retrieval_service.dart'
    as _i984;
import 'package:ssurade_adaptor/crawling/service/external_scholarship_manager_retrieval_service.dart'
    as _i675;
import 'package:ssurade_adaptor/crawling/service/external_subject_retrieval_service.dart'
    as _i683;
import 'package:ssurade_adaptor/crawling/webview/web_view_client_service.dart'
    as _i722;
import 'package:ssurade_adaptor/persistence/client/local_storage_client.dart'
    as _i289;
import 'package:ssurade_adaptor/persistence/client/secure_storage_client.dart'
    as _i497;
import 'package:ssurade_adaptor/persistence/service/lightspeed_retrieval_service.dart'
    as _i460;
import 'package:ssurade_adaptor/persistence/service/local_storage_absent_application_manager_service.dart'
    as _i470;
import 'package:ssurade_adaptor/persistence/service/local_storage_background_setting_service.dart'
    as _i994;
import 'package:ssurade_adaptor/persistence/service/local_storage_chapel_manager_service.dart'
    as _i1004;
import 'package:ssurade_adaptor/persistence/service/local_storage_credential_service.dart'
    as _i1054;
import 'package:ssurade_adaptor/persistence/service/local_storage_scholarship_manager_service.dart'
    as _i109;
import 'package:ssurade_adaptor/persistence/service/local_storage_semester_subjects_manager_service.dart'
    as _i388;
import 'package:ssurade_adaptor/persistence/service/local_storage_setting_service.dart'
    as _i86;
import 'package:ssurade_application/ssurade_application.dart' as _i67;

class SsuradeAdaptorPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) async {
    final localStorageChapelManagerServiceModule =
        _$LocalStorageChapelManagerServiceModule();
    final localStorageSettingServiceModule =
        _$LocalStorageSettingServiceModule();
    final localStorageCredentialServiceModule =
        _$LocalStorageCredentialServiceModule();
    final localStorageScholarshipManagerServiceModule =
        _$LocalStorageScholarshipManagerServiceModule();
    final localStorageAbsentApplicationManagerServiceModule =
        _$LocalStorageAbsentApplicationManagerServiceModule();
    final localStorageBackgroundSettingServiceModule =
        _$LocalStorageBackgroundSettingServiceModule();
    final localStorageSemesterSubjectsManagerServiceModule =
        _$LocalStorageSemesterSubjectsManagerServiceModule();
    gh.factory<_i67.LocalStorageChapelManagerRetrievalPort>(
        () => localStorageChapelManagerServiceModule.i1);
    gh.factory<_i67.LocalStorageChapelManagerSavePort>(
        () => localStorageChapelManagerServiceModule.i2);
    gh.factory<_i67.LocalStorageSettingRetrievalPort>(
        () => localStorageSettingServiceModule.i1);
    gh.factory<_i67.LocalStorageSettingSavePort>(
        () => localStorageSettingServiceModule.i2);
    gh.factory<_i67.LocalStorageCredentialRetrievalPort>(
        () => localStorageCredentialServiceModule.i1);
    gh.factory<_i67.LocalStorageCredentialSavePort>(
        () => localStorageCredentialServiceModule.i2);
    gh.factory<_i67.LocalStorageScholarshipManagerRetrievalPort>(
        () => localStorageScholarshipManagerServiceModule.i1);
    gh.factory<_i67.LocalStorageScholarshipManagerSavePort>(
        () => localStorageScholarshipManagerServiceModule.i2);
    gh.factory<_i67.LocalStorageAbsentApplicationManagerRetrievalPort>(
        () => localStorageAbsentApplicationManagerServiceModule.i1);
    gh.factory<_i67.LocalStorageAbsentApplicationManagerSavePort>(
        () => localStorageAbsentApplicationManagerServiceModule.i2);
    gh.factory<_i67.LocalStorageBackgroundSettingRetrievalPort>(
        () => localStorageBackgroundSettingServiceModule.i1);
    gh.factory<_i67.LocalStorageBackgroundSettingSavePort>(
        () => localStorageBackgroundSettingServiceModule.i2);
    gh.factory<_i67.LocalStorageSemesterSubjectsManagerRetrievalPort>(
        () => localStorageSemesterSubjectsManagerServiceModule.i1);
    gh.factory<_i67.LocalStorageSemesterSubjectsManagerSavePort>(
        () => localStorageSemesterSubjectsManagerServiceModule.i2);
    await gh.singletonAsync<_i289.LocalStorageClient>(
      () => _i289.LocalStorageClient.init(),
      preResolve: true,
    );
    gh.singleton<_i497.SecureStorageClient>(
        () => const _i497.SecureStorageClient());
    gh.singleton<_i67.LightspeedRetrievalPort>(
        () => _i460.LightspeedRetrievalService(gh<_i289.LocalStorageClient>()));
    gh.singleton<_i1004.LocalStorageChapelManagerService>(() =>
        _i1004.LocalStorageChapelManagerService(
            gh<_i289.LocalStorageClient>()));
    gh.singleton<_i86.LocalStorageSettingService>(
        () => _i86.LocalStorageSettingService(gh<_i289.LocalStorageClient>()));
    gh.singleton<_i109.LocalStorageScholarshipManagerService>(() =>
        _i109.LocalStorageScholarshipManagerService(
            gh<_i289.LocalStorageClient>()));
    gh.singleton<_i470.LocalStorageAbsentApplicationManagerService>(() =>
        _i470.LocalStorageAbsentApplicationManagerService(
            gh<_i289.LocalStorageClient>()));
    gh.singleton<_i994.LocalStorageBackgroundSettingService>(() =>
        _i994.LocalStorageBackgroundSettingService(
            gh<_i289.LocalStorageClient>()));
    gh.singleton<_i388.LocalStorageSemesterSubjectsManagerService>(() =>
        _i388.LocalStorageSemesterSubjectsManagerService(
            gh<_i289.LocalStorageClient>()));
    gh.singleton<_i1054.LocalStorageCredentialService>(() =>
        _i1054.LocalStorageCredentialService(gh<_i497.SecureStorageClient>()));
    gh.singleton<_i722.WebViewClientService>(() => _i722.WebViewClientService(
          credentialRetrievalPort:
              gh<_i67.LocalStorageCredentialRetrievalPort>(),
          credentialSavePort: gh<_i67.LocalStorageCredentialSavePort>(),
          lightspeedRetrievalPort: gh<_i67.LightspeedRetrievalPort>(),
        ));
    gh.singleton<_i67.ExternalSubjectRetrievalPort>(() =>
        _i683.ExternalSubjectRetrievalService(
            gh<_i722.WebViewClientService>()));
    gh.singleton<_i67.ExternalAbsentApplicationRetrievalPort>(() =>
        _i507.ExternalAbsentApplicationRetrievalService(
            gh<_i722.WebViewClientService>()));
    gh.singleton<_i67.ExternalScholarshipManagerRetrievalPort>(() =>
        _i675.ExternalScholarshipManagerRetrievalService(
            gh<_i722.WebViewClientService>()));
    gh.singleton<_i67.ExternalChapelManagerRetrievalPort>(() =>
        _i984.ExternalChapelRetrievalService(gh<_i722.WebViewClientService>()));
  }
}

class _$LocalStorageChapelManagerServiceModule
    extends _i1004.LocalStorageChapelManagerServiceModule {}

class _$LocalStorageSettingServiceModule
    extends _i86.LocalStorageSettingServiceModule {}

class _$LocalStorageCredentialServiceModule
    extends _i1054.LocalStorageCredentialServiceModule {}

class _$LocalStorageScholarshipManagerServiceModule
    extends _i109.LocalStorageScholarshipManagerServiceModule {}

class _$LocalStorageAbsentApplicationManagerServiceModule
    extends _i470.LocalStorageAbsentApplicationManagerServiceModule {}

class _$LocalStorageBackgroundSettingServiceModule
    extends _i994.LocalStorageBackgroundSettingServiceModule {}

class _$LocalStorageSemesterSubjectsManagerServiceModule
    extends _i388.LocalStorageSemesterSubjectsManagerServiceModule {}
