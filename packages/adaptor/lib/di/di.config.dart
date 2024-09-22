// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:ssurade_adaptor/application/app_environment_service.dart' as _i78;
import 'package:ssurade_adaptor/application/app_version_fetch_service.dart' as _i159;
import 'package:ssurade_adaptor/application/background/background_process_management_service.dart' as _i717;
import 'package:ssurade_adaptor/application/notification_service.dart' as _i762;
import 'package:ssurade_adaptor/crawling/service/external_absent_application_retrieval_service.dart' as _i507;
import 'package:ssurade_adaptor/crawling/service/external_chapel_retrieval_service.dart' as _i984;
import 'package:ssurade_adaptor/crawling/service/external_credential_retrieval_service.dart' as _i333;
import 'package:ssurade_adaptor/crawling/service/external_scholarship_manager_retrieval_service.dart' as _i675;
import 'package:ssurade_adaptor/crawling/service/external_subject_retrieval_service.dart' as _i683;
import 'package:ssurade_adaptor/crawling/webview/web_view_client_service.dart' as _i722;
import 'package:ssurade_adaptor/persistence/client/local_storage_client.dart' as _i289;
import 'package:ssurade_adaptor/persistence/client/secure_storage_client.dart' as _i497;
import 'package:ssurade_adaptor/persistence/service/lightspeed_retrieval_service.dart' as _i460;
import 'package:ssurade_adaptor/persistence/service/local_storage_absent_application_manager_service.dart' as _i470;
import 'package:ssurade_adaptor/persistence/service/local_storage_chapel_manager_service.dart' as _i1004;
import 'package:ssurade_adaptor/persistence/service/local_storage_credential_service.dart' as _i1054;
import 'package:ssurade_adaptor/persistence/service/local_storage_scholarship_manager_service.dart' as _i109;
import 'package:ssurade_adaptor/persistence/service/local_storage_semester_subjects_manager_service.dart' as _i388;
import 'package:ssurade_adaptor/persistence/service/local_storage_setting_service.dart' as _i86;
import 'package:ssurade_application/port/out/application/app_environment_port.dart' as _i124;
import 'package:ssurade_application/port/out/application/app_version_fetch_port.dart' as _i747;
import 'package:ssurade_application/port/out/application/background_process_management_port.dart' as _i975;
import 'package:ssurade_application/port/out/application/notification_port.dart' as _i77;
import 'package:ssurade_application/port/out/external/external_credential_retrieval_port.dart' as _i1067;
import 'package:ssurade_application/ssurade_application.dart' as _i67;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final localStorageChapelManagerServiceModule = _$LocalStorageChapelManagerServiceModule();
    final localStorageSettingServiceModule = _$LocalStorageSettingServiceModule();
    final localStorageCredentialServiceModule = _$LocalStorageCredentialServiceModule();
    final localStorageScholarshipManagerServiceModule = _$LocalStorageScholarshipManagerServiceModule();
    final localStorageAbsentApplicationManagerServiceModule = _$LocalStorageAbsentApplicationManagerServiceModule();
    final localStorageSemesterSubjectsManagerServiceModule = _$LocalStorageSemesterSubjectsManagerServiceModule();
    gh.factory<_i67.LocalStorageChapelManagerRetrievalPort>(() => localStorageChapelManagerServiceModule.i1);
    gh.factory<_i67.LocalStorageChapelManagerSavePort>(() => localStorageChapelManagerServiceModule.i2);
    gh.factory<_i67.LocalStorageSettingRetrievalPort>(() => localStorageSettingServiceModule.i1);
    gh.factory<_i67.LocalStorageSettingSavePort>(() => localStorageSettingServiceModule.i2);
    gh.factory<_i67.LocalStorageCredentialRetrievalPort>(() => localStorageCredentialServiceModule.i1);
    gh.factory<_i67.LocalStorageCredentialSavePort>(() => localStorageCredentialServiceModule.i2);
    gh.factory<_i67.LocalStorageScholarshipManagerRetrievalPort>(() => localStorageScholarshipManagerServiceModule.i1);
    gh.factory<_i67.LocalStorageScholarshipManagerSavePort>(() => localStorageScholarshipManagerServiceModule.i2);
    gh.factory<_i67.LocalStorageAbsentApplicationManagerRetrievalPort>(() => localStorageAbsentApplicationManagerServiceModule.i1);
    gh.factory<_i67.LocalStorageAbsentApplicationManagerSavePort>(() => localStorageAbsentApplicationManagerServiceModule.i2);
    gh.factory<_i67.LocalStorageSemesterSubjectsManagerRetrievalPort>(() => localStorageSemesterSubjectsManagerServiceModule.i1);
    gh.factory<_i67.LocalStorageSemesterSubjectsManagerSavePort>(() => localStorageSemesterSubjectsManagerServiceModule.i2);
    await gh.singletonAsync<_i289.LocalStorageClient>(
      () => _i289.LocalStorageClient.init(),
      preResolve: true,
    );
    gh.singleton<_i497.SecureStorageClient>(() => const _i497.SecureStorageClient());
    gh.singleton<_i67.LightspeedRetrievalPort>(() => _i460.LightspeedRetrievalService(gh<_i289.LocalStorageClient>()));
    await gh.singletonAsync<_i975.BackgroundProcessManagementPort>(
      () => _i717.BackgroundProcessManagementService.init(),
      preResolve: true,
    );
    await gh.singletonAsync<_i77.NotificationPort>(
      () => _i762.NotificationService.init(),
      preResolve: true,
    );
    gh.singleton<_i747.AppVersionFetchPort>(() => _i159.AppVersionFetchService());
    gh.singleton<_i1004.LocalStorageChapelManagerService>(() => _i1004.LocalStorageChapelManagerService(gh<_i289.LocalStorageClient>()));
    gh.singleton<_i86.LocalStorageSettingService>(() => _i86.LocalStorageSettingService(gh<_i289.LocalStorageClient>()));
    gh.singleton<_i109.LocalStorageScholarshipManagerService>(() => _i109.LocalStorageScholarshipManagerService(gh<_i289.LocalStorageClient>()));
    gh.singleton<_i470.LocalStorageAbsentApplicationManagerService>(() => _i470.LocalStorageAbsentApplicationManagerService(gh<_i289.LocalStorageClient>()));
    gh.singleton<_i388.LocalStorageSemesterSubjectsManagerService>(() => _i388.LocalStorageSemesterSubjectsManagerService(gh<_i289.LocalStorageClient>()));
    gh.singleton<_i124.AppEnvironmentPort>(() => _i78.AppEnvironmentService());
    gh.singleton<_i1054.LocalStorageCredentialService>(() => _i1054.LocalStorageCredentialService(gh<_i497.SecureStorageClient>()));
    gh.singleton<_i722.WebViewClientService>(() => _i722.WebViewClientService(
          credentialRetrievalPort: gh<_i67.LocalStorageCredentialRetrievalPort>(),
          credentialSavePort: gh<_i67.LocalStorageCredentialSavePort>(),
          lightspeedRetrievalPort: gh<_i67.LightspeedRetrievalPort>(),
        ));
    gh.singleton<_i67.ExternalSubjectRetrievalPort>(() => _i683.ExternalSubjectRetrievalService(gh<_i722.WebViewClientService>()));
    gh.singleton<_i67.ExternalAbsentApplicationRetrievalPort>(() => _i507.ExternalAbsentApplicationRetrievalService(gh<_i722.WebViewClientService>()));
    gh.singleton<_i67.ExternalScholarshipManagerRetrievalPort>(() => _i675.ExternalScholarshipManagerRetrievalService(gh<_i722.WebViewClientService>()));
    gh.singleton<_i67.ExternalChapelManagerRetrievalPort>(() => _i984.ExternalChapelRetrievalService(gh<_i722.WebViewClientService>()));
    gh.singleton<_i1067.ExternalCredentialRetrievalPort>(() => _i333.ExternalCredentialRetrievalService(gh<_i722.WebViewClientService>()));
    await _i67.SsuradeApplicationPackageModule().init(gh);
    return this;
  }
}

class _$LocalStorageChapelManagerServiceModule extends _i1004.LocalStorageChapelManagerServiceModule {}

class _$LocalStorageSettingServiceModule extends _i86.LocalStorageSettingServiceModule {}

class _$LocalStorageCredentialServiceModule extends _i1054.LocalStorageCredentialServiceModule {}

class _$LocalStorageScholarshipManagerServiceModule extends _i109.LocalStorageScholarshipManagerServiceModule {}

class _$LocalStorageAbsentApplicationManagerServiceModule extends _i470.LocalStorageAbsentApplicationManagerServiceModule {}

class _$LocalStorageSemesterSubjectsManagerServiceModule extends _i388.LocalStorageSemesterSubjectsManagerServiceModule {}
