import 'dart:async';
import 'dart:typed_data';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_application/domain/model/semester/year_semester.dart';
import 'package:ssurade_application/domain/model/subject/semester_subjects_manager.dart';
import 'package:ssurade_application/port/in/viewmodel/subject_view_model_use_case.dart';
import 'package:ssurade_application/port/out/application/toast_port.dart';
import 'package:ssurade_application/port/out/external/external_subject_retrieval_port.dart';
import 'package:ssurade_application/port/out/local_storage/local_storage_save_photo_port.dart';
import 'package:ssurade_application/port/out/local_storage/local_storage_semester_subjects_manager_port.dart';

@Singleton(as: SubjectViewModelUseCase)
class SubjectViewModelService implements SubjectViewModelUseCase {
  final StreamController<SemesterSubjectsManager> _streamController = StreamController.broadcast();
  final LocalStorageSemesterSubjectsManagerPort _localStorageSemesterSubjectsManagerPort;
  final ExternalSubjectRetrievalPort _externalSubjectRetrievalPort;
  final LocalStorageSavePhotoPort _localStorageSavePhotoPort;
  final ToastPort _toastPort;

  SubjectViewModelService({
    required LocalStorageSemesterSubjectsManagerPort localStorageSemesterSubjectsManagerPort,
    required ExternalSubjectRetrievalPort externalSubjectRetrievalPort,
    required LocalStorageSavePhotoPort localStorageSavePhotoPort,
    required ToastPort toastPort,
  })  : _localStorageSemesterSubjectsManagerPort = localStorageSemesterSubjectsManagerPort,
        _externalSubjectRetrievalPort = externalSubjectRetrievalPort,
        _localStorageSavePhotoPort = localStorageSavePhotoPort,
        _toastPort = toastPort;

  @override
  Future<SemesterSubjectsManager?> getSemesterSubjectsManager() {
    return _localStorageSemesterSubjectsManagerPort.retrieveSemesterSubjectsManager();
  }

  @override
  Future<bool> loadNewSemesterSubjects(YearSemester yearSemester) async {
    final semesterSubjects = await _externalSubjectRetrievalPort.retrieveSemesterSubjects(yearSemester, includeDetail: true).result;
    final currentSemesterSubjectsManager = await getSemesterSubjectsManager();
    if (semesterSubjects != null && currentSemesterSubjectsManager != null) {
      final nextSemesterSubjectsManager = currentSemesterSubjectsManager.copyWith(data: currentSemesterSubjectsManager.data.also((it) {
        it[yearSemester] = semesterSubjects;
      }));
      await _localStorageSemesterSubjectsManagerPort.saveSemesterSubjectsManager(nextSemesterSubjectsManager);
      _streamController.add(nextSemesterSubjectsManager);
      return true;
    }
    return false;
  }

  @override
  Future<bool> loadNewSemesterSubjectsManager() async {
    final semesterSubjectsManager = await _externalSubjectRetrievalPort.retrieveAllSemesterSubjects(includeDetail: true).result;
    if (semesterSubjectsManager != null) {
      await _localStorageSemesterSubjectsManagerPort.saveSemesterSubjectsManager(semesterSubjectsManager);
      _streamController.add(semesterSubjectsManager);
      return true;
    }
    return false;
  }

  @override
  Future<void> clearSemesterSubjectsManager() async {
    final semesterSubjectsManager = SemesterSubjectsManager.empty();
    await _localStorageSemesterSubjectsManagerPort.saveSemesterSubjectsManager(semesterSubjectsManager);
    _streamController.add(semesterSubjectsManager);
  }

  @override
  Stream<SemesterSubjectsManager> getSemesterSubjectsManagerStream() {
    return _streamController.stream.asBroadcastStream();
  }

  @override
  Future<void> saveScreenshotInGallery({required Uint8List data, required String name}) async {
    await _localStorageSavePhotoPort.savePhotoInGallery(data: data, name: name);
  }

  @override
  Future<void> showToast(String message) async {
    await _toastPort.showToast(message);
  }
}
