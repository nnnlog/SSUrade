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
import 'package:ssurade_adaptor/application/toast_service.dart' as _i114;
import 'package:ssurade_adaptor/asset/asset_loader_service.dart' as _i27;
import 'package:ssurade_adaptor/crawling/cache/credential_manager_service.dart' as _i903;
import 'package:ssurade_adaptor/crawling/service/credential/credential_retrieval_service.dart' as _i202;
import 'package:ssurade_adaptor/crawling/service/external_absent_application_retrieval_service.dart' as _i507;
import 'package:ssurade_adaptor/crawling/service/external_chapel_retrieval_service.dart' as _i984;
import 'package:ssurade_adaptor/crawling/service/external_credential_retrieval_service.dart' as _i333;
import 'package:ssurade_adaptor/crawling/service/external_scholarship_manager_retrieval_service.dart' as _i675;
import 'package:ssurade_adaptor/crawling/service/external_subject_retrieval_service.dart' as _i683;
import 'package:ssurade_adaptor/crawling/webview/web_view_client_service.dart' as _i722;
import 'package:ssurade_adaptor/persistence/client/local_storage_client.dart' as _i289;
import 'package:ssurade_adaptor/persistence/client/secure_storage_client.dart' as _i497;
import 'package:ssurade_adaptor/persistence/localstorage/lightspeed_retrieval_service.dart' as _i615;
import 'package:ssurade_adaptor/persistence/localstorage/local_storage_absent_application_manager_service.dart' as _i420;
import 'package:ssurade_adaptor/persistence/localstorage/local_storage_chapel_manager_service.dart' as _i69;
import 'package:ssurade_adaptor/persistence/localstorage/local_storage_credential_service.dart' as _i101;
import 'package:ssurade_adaptor/persistence/localstorage/local_storage_save_photo_service.dart' as _i524;
import 'package:ssurade_adaptor/persistence/localstorage/local_storage_scholarship_manager_service.dart' as _i750;
import 'package:ssurade_adaptor/persistence/localstorage/local_storage_semester_subjects_manager_service.dart' as _i139;
import 'package:ssurade_adaptor/persistence/localstorage/local_storage_setting_service.dart' as _i47;
import 'package:ssurade_application/port/out/application/app_environment_port.dart' as _i124;
import 'package:ssurade_application/port/out/application/app_version_fetch_port.dart' as _i747;
import 'package:ssurade_application/port/out/application/background_process_management_port.dart' as _i975;
import 'package:ssurade_application/port/out/application/notification_port.dart' as _i77;
import 'package:ssurade_application/port/out/application/toast_port.dart' as _i750;
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
    final localStorageCredentialServiceModule = _$LocalStorageCredentialServiceModule();
    final externalCredentialRetrievalServiceModule = _$ExternalCredentialRetrievalServiceModule();
    gh.factory<_i67.LocalStorageCredentialPort>(() => localStorageCredentialServiceModule.localStorageCredentialPort);
    gh.factory<_i1067.ExternalCredentialRetrievalPort>(() => externalCredentialRetrievalServiceModule.externalCredentialRetrievalPort);
    gh.singleton<_i27.AssetLoaderService>(() => _i27.AssetLoaderService());
    await gh.singletonAsync<_i289.LocalStorageClient>(
      () => _i289.LocalStorageClient.init(),
      preResolve: true,
    );
    gh.singleton<_i497.SecureStorageClient>(() => const _i497.SecureStorageClient());
    gh.singleton<_i202.CredentialRetrievalService>(() => _i202.CredentialRetrievalService());
    await gh.singletonAsync<_i975.BackgroundProcessManagementPort>(
      () => _i717.BackgroundProcessManagementService.init(),
      preResolve: true,
    );
    await gh.singletonAsync<_i77.NotificationPort>(
      () => _i762.NotificationService.init(),
      preResolve: true,
    );
    gh.singleton<_i747.AppVersionFetchPort>(() => _i159.AppVersionFetchService());
    gh.singleton<_i67.LocalStorageScholarshipManagerPort>(() => _i750.LocalStorageScholarshipManagerService(gh<_i289.LocalStorageClient>()));
    gh.singleton<_i67.LocalStorageSavePhotoPort>(() => _i524.LocalStorageSavePhotoService());
    gh.singleton<_i67.LocalStorageChapelManagerPort>(() => _i69.LocalStorageChapelManagerService(gh<_i289.LocalStorageClient>()));
    gh.singleton<_i750.ToastPort>(() => _i114.ToastService());
    gh.singleton<_i67.LocalStorageAbsentApplicationManagerPort>(() => _i420.LocalStorageAbsentApplicationManagerService(gh<_i289.LocalStorageClient>()));
    gh.singleton<_i67.LocalStorageSemesterSubjectsManagerPort>(() => _i139.LocalStorageSemesterSubjectsManagerService(gh<_i289.LocalStorageClient>()));
    gh.singleton<_i615.LightspeedRetrievalService>(() => _i615.LightspeedRetrievalService(gh<_i289.LocalStorageClient>()));
    gh.singleton<_i67.LocalStorageSettingPort>(() => _i47.LocalStorageSettingService(gh<_i289.LocalStorageClient>()));
    gh.singleton<_i124.AppEnvironmentPort>(() => _i78.AppEnvironmentService());
    gh.singleton<_i101.LocalStorageCredentialService>(() => _i101.LocalStorageCredentialService(gh<_i497.SecureStorageClient>()));
    gh.singleton<_i903.CredentialManagerService>(() => _i903.CredentialManagerService(
          localStorageClient: gh<_i289.LocalStorageClient>(),
          localStorageCredentialService: gh<_i101.LocalStorageCredentialService>(),
          credentialRetrievalService: gh<_i202.CredentialRetrievalService>(),
        ));
    gh.singleton<_i722.WebViewClientService>(() => _i722.WebViewClientService(
          credentialCacheService: gh<_i903.CredentialManagerService>(),
          lightspeedRetrievalService: gh<_i615.LightspeedRetrievalService>(),
          assetLoaderService: gh<_i27.AssetLoaderService>(),
        ));
    gh.singleton<_i67.ExternalSubjectRetrievalPort>(() => _i683.ExternalSubjectRetrievalService(gh<_i722.WebViewClientService>()));
    gh.singleton<_i67.ExternalAbsentApplicationRetrievalPort>(() => _i507.ExternalAbsentApplicationRetrievalService(gh<_i722.WebViewClientService>()));
    gh.singleton<_i333.ExternalCredentialRetrievalService>(() => _i333.ExternalCredentialRetrievalService(
          gh<_i722.WebViewClientService>(),
          gh<_i202.CredentialRetrievalService>(),
        ));
    gh.singleton<_i67.ExternalScholarshipManagerRetrievalPort>(() => _i675.ExternalScholarshipManagerRetrievalService(gh<_i722.WebViewClientService>()));
    gh.singleton<_i67.ExternalChapelManagerRetrievalPort>(() => _i984.ExternalChapelRetrievalService(gh<_i722.WebViewClientService>()));
    await _i67.SsuradeApplicationPackageModule().init(gh);
    return this;
  }
}

class _$LocalStorageCredentialServiceModule extends _i101.LocalStorageCredentialServiceModule {}

class _$ExternalCredentialRetrievalServiceModule extends _i333.ExternalCredentialRetrievalServiceModule {}
