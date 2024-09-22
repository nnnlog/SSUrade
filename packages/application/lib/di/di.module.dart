//@GeneratedMicroModule;SsuradeApplicationPackageModule;package:ssurade_application/di/di.module.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:injectable/injectable.dart' as _i526;
import 'package:ssurade_application/domain/service/background/background_process_service.dart' as _i334;
import 'package:ssurade_application/port/in/background/background_process_use_case.dart' as _i356;
import 'package:ssurade_application/port/out/application/app_environment_port.dart' as _i124;
import 'package:ssurade_application/port/out/application/notification_port.dart' as _i77;
import 'package:ssurade_application/port/out/external/external_absent_application_retrieval_port.dart' as _i179;
import 'package:ssurade_application/port/out/external/external_chapel_retrieval_port.dart' as _i751;
import 'package:ssurade_application/port/out/external/external_scholarship_manager_retrieval_port.dart' as _i619;
import 'package:ssurade_application/port/out/external/external_subject_retrieval_port.dart' as _i273;
import 'package:ssurade_application/port/out/local_storage/retrieval/local_storage_absent_application_manager_retrieval_port.dart' as _i252;
import 'package:ssurade_application/port/out/local_storage/retrieval/local_storage_chapel_manager_retrieval_port.dart' as _i1066;
import 'package:ssurade_application/port/out/local_storage/retrieval/local_storage_scholarship_manager_retrieval_port.dart' as _i291;
import 'package:ssurade_application/port/out/local_storage/retrieval/local_storage_semester_subjects_manager_retrieval_port.dart' as _i806;
import 'package:ssurade_application/port/out/local_storage/retrieval/local_storage_setting_retrieval_port.dart' as _i804;
import 'package:ssurade_application/port/out/local_storage/save/local_storage_absent_application_manager_save_port.dart' as _i738;
import 'package:ssurade_application/port/out/local_storage/save/local_storage_chapel_manager_save_port.dart' as _i819;
import 'package:ssurade_application/port/out/local_storage/save/local_storage_scholarship_manager_save_port.dart' as _i890;
import 'package:ssurade_application/port/out/local_storage/save/local_storage_semester_subjects_manager_save_port.dart' as _i739;

class SsuradeApplicationPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.singleton<_i356.BackgroundProcessUseCase>(() => _i334.BackgroundProcessService(
          gh<_i252.LocalStorageAbsentApplicationManagerRetrievalPort>(),
          gh<_i738.LocalStorageAbsentApplicationManagerSavePort>(),
          gh<_i179.ExternalAbsentApplicationRetrievalPort>(),
          gh<_i1066.LocalStorageChapelManagerRetrievalPort>(),
          gh<_i819.LocalStorageChapelManagerSavePort>(),
          gh<_i751.ExternalChapelManagerRetrievalPort>(),
          gh<_i806.LocalStorageSemesterSubjectsManagerRetrievalPort>(),
          gh<_i739.LocalStorageSemesterSubjectsManagerSavePort>(),
          gh<_i273.ExternalSubjectRetrievalPort>(),
          gh<_i291.LocalStorageScholarshipManagerRetrievalPort>(),
          gh<_i890.LocalStorageScholarshipManagerSavePort>(),
          gh<_i619.ExternalScholarshipManagerRetrievalPort>(),
          gh<_i804.LocalStorageSettingRetrievalPort>(),
          gh<_i77.NotificationPort>(),
          gh<_i124.AppEnvironmentPort>(),
        ));
  }
}
