import 'dart:async';
import 'dart:collection';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_application/domain/model/chapel/chapel.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_attendance.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_attendance_status.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_manager.dart';
import 'package:ssurade_application/domain/model/scholarship/scholarship_manager.dart';
import 'package:ssurade_application/domain/model/semester/year_semester.dart';
import 'package:ssurade_application/port/in/viewmodel/chapel_view_model_use_case.dart';
import 'package:ssurade_application/port/in/viewmodel/scholarship_view_model_use_case.dart';
import 'package:ssurade_application/port/out/application/toast_port.dart';
import 'package:ssurade_application/port/out/external/external_chapel_retrieval_port.dart';
import 'package:ssurade_application/port/out/external/external_scholarship_manager_retrieval_port.dart';
import 'package:ssurade_application/port/out/local_storage/local_storage_chapel_manager_port.dart';
import 'package:ssurade_application/port/out/local_storage/local_storage_scholarship_manager_port.dart';
import 'package:ssurade_application/port/out/local_storage/local_storage_semester_subjects_manager_port.dart';

@Singleton(as: ScholarshipViewModelUseCase)
class ScholarshipViewModelService implements ScholarshipViewModelUseCase {
  final StreamController<ScholarshipManager> _streamController = StreamController.broadcast();
  final LocalStorageScholarshipManagerPort _localStorageScholarshipManagerPort;
  final ExternalScholarshipManagerRetrievalPort _externalScholarshipManagerRetrievalPort;
  final ToastPort _toastPort;

  ScholarshipViewModelService({
    required LocalStorageScholarshipManagerPort localStorageScholarshipManagerPort,
    required ExternalScholarshipManagerRetrievalPort externalScholarshipManagerRetrievalPort,
    required ToastPort toastPort,
  })  : _localStorageScholarshipManagerPort = localStorageScholarshipManagerPort,
        _externalScholarshipManagerRetrievalPort = externalScholarshipManagerRetrievalPort,
        _toastPort = toastPort;

  @override
  Future<ScholarshipManager?> getScholarshipManager() {
    return _localStorageScholarshipManagerPort.retrieveScholarshipManager();
  }

  @override
  Future<bool> loadNewScholarshipManager() async {
    var scholarshipManager = await _externalScholarshipManagerRetrievalPort.retrieveScholarshipManager().result;
    if (scholarshipManager == null) {
      await _toastPort.showToast('Failed to load scholarship manager');
      return false;
    }

    await _localStorageScholarshipManagerPort.saveScholarshipManager(scholarshipManager);
    _streamController.add(scholarshipManager);
    return true;
  }

  @override
  Future<void> clearScholarshipManager() async {
    final chapelManager = ScholarshipManager.empty();
    await _localStorageScholarshipManagerPort.saveScholarshipManager(chapelManager);
    _streamController.add(chapelManager);
  }

  @override
  Stream<ScholarshipManager> getScholarshipManagerStream() {
    return _streamController.stream.asBroadcastStream();
  }

  @override
  Future<void> showToast(String message) async {
    await _toastPort.showToast(message);
  }
}
