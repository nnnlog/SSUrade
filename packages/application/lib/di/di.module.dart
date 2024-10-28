//@GeneratedMicroModule;SsuradeApplicationPackageModule;package:ssurade_application/di/di.module.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:injectable/injectable.dart' as _i526;
import 'package:ssurade_application/domain/service/background/background_process_service.dart' as _i334;
import 'package:ssurade_application/domain/service/viewmodel/login_view_model_service.dart' as _i919;
import 'package:ssurade_application/domain/service/viewmodel/subject_view_model_service.dart' as _i345;
import 'package:ssurade_application/port/in/background/background_process_use_case.dart' as _i356;
import 'package:ssurade_application/port/in/viewmodel/login_view_model_use_case.dart' as _i273;
import 'package:ssurade_application/port/in/viewmodel/subject_view_model_use_case.dart' as _i315;
import 'package:ssurade_application/port/out/application/app_environment_port.dart' as _i124;
import 'package:ssurade_application/port/out/application/notification_port.dart' as _i77;
import 'package:ssurade_application/port/out/application/toast_port.dart' as _i750;
import 'package:ssurade_application/port/out/external/external_absent_application_retrieval_port.dart' as _i179;
import 'package:ssurade_application/port/out/external/external_chapel_retrieval_port.dart' as _i751;
import 'package:ssurade_application/port/out/external/external_credential_retrieval_port.dart' as _i1067;
import 'package:ssurade_application/port/out/external/external_scholarship_manager_retrieval_port.dart' as _i619;
import 'package:ssurade_application/port/out/external/external_subject_retrieval_port.dart' as _i273;
import 'package:ssurade_application/port/out/local_storage/local_storage_absent_application_manager_port.dart' as _i862;
import 'package:ssurade_application/port/out/local_storage/local_storage_chapel_manager_port.dart' as _i833;
import 'package:ssurade_application/port/out/local_storage/local_storage_credential_port.dart' as _i792;
import 'package:ssurade_application/port/out/local_storage/local_storage_save_photo_port.dart' as _i537;
import 'package:ssurade_application/port/out/local_storage/local_storage_scholarship_manager_port.dart' as _i411;
import 'package:ssurade_application/port/out/local_storage/local_storage_semester_subjects_manager_port.dart' as _i741;
import 'package:ssurade_application/port/out/local_storage/local_storage_setting_port.dart' as _i993;

class SsuradeApplicationPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.singleton<_i356.BackgroundProcessUseCase>(() => _i334.BackgroundProcessService(
          gh<_i862.LocalStorageAbsentApplicationManagerPort>(),
          gh<_i179.ExternalAbsentApplicationRetrievalPort>(),
          gh<_i833.LocalStorageChapelManagerPort>(),
          gh<_i751.ExternalChapelManagerRetrievalPort>(),
          gh<_i741.LocalStorageSemesterSubjectsManagerPort>(),
          gh<_i273.ExternalSubjectRetrievalPort>(),
          gh<_i411.LocalStorageScholarshipManagerPort>(),
          gh<_i619.ExternalScholarshipManagerRetrievalPort>(),
          gh<_i993.LocalStorageSettingPort>(),
          gh<_i77.NotificationPort>(),
          gh<_i124.AppEnvironmentPort>(),
        ));
    gh.singleton<_i315.SubjectViewModelUseCase>(() => _i345.SubjectViewModelService(
          localStorageSemesterSubjectsManagerPort: gh<_i741.LocalStorageSemesterSubjectsManagerPort>(),
          externalSubjectRetrievalPort: gh<_i273.ExternalSubjectRetrievalPort>(),
          localStorageSavePhotoPort: gh<_i537.LocalStorageSavePhotoPort>(),
          toastPort: gh<_i750.ToastPort>(),
        ));
    gh.singleton<_i273.LoginViewModelUseCase>(() => _i919.LoginViewModelService(
          localStorageCredentialPort: gh<_i792.LocalStorageCredentialPort>(),
          externalCredentialRetrievalPort: gh<_i1067.ExternalCredentialRetrievalPort>(),
        ));
  }
}