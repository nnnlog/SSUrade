import 'dart:async';
import 'dart:collection';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_application/domain/model/chapel/chapel.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_attendance.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_attendance_status.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_manager.dart';
import 'package:ssurade_application/domain/model/semester/year_semester.dart';
import 'package:ssurade_application/port/in/viewmodel/chapel_view_model_use_case.dart';
import 'package:ssurade_application/port/out/application/toast_port.dart';
import 'package:ssurade_application/port/out/external/external_chapel_retrieval_port.dart';
import 'package:ssurade_application/port/out/local_storage/local_storage_chapel_manager_port.dart';
import 'package:ssurade_application/port/out/local_storage/local_storage_semester_subjects_manager_port.dart';

@Singleton(as: ChapelViewModelUseCase)
class ChapelViewModelService implements ChapelViewModelUseCase {
  final StreamController<ChapelManager> _streamController = StreamController.broadcast();
  final LocalStorageSemesterSubjectsManagerPort _localStorageSemesterSubjectsManagerPort;
  final LocalStorageChapelManagerPort _localStorageChapelManagerPort;
  final ExternalChapelManagerRetrievalPort _externalChapelManagerRetrievalPort;
  final ToastPort _toastPort;

  ChapelViewModelService({
    required LocalStorageSemesterSubjectsManagerPort localStorageSemesterSubjectsManagerPort,
    required LocalStorageChapelManagerPort localStorageChapelManagerPort,
    required ExternalChapelManagerRetrievalPort externalSubjectRetrievalPort,
    required ToastPort toastPort,
  })  : _localStorageSemesterSubjectsManagerPort = localStorageSemesterSubjectsManagerPort,
        _localStorageChapelManagerPort = localStorageChapelManagerPort,
        _externalChapelManagerRetrievalPort = externalSubjectRetrievalPort,
        _toastPort = toastPort;

  @override
  Future<ChapelManager?> getChapelManager() {
    return _localStorageChapelManagerPort.retrieveChapelManager();
  }

  @override
  Future<bool> loadNewChapel(YearSemester yearSemester) async {
    final semesterSubjects = await _externalChapelManagerRetrievalPort.retrieveChapel(yearSemester).result;
    final currentChapelManager = await getChapelManager();
    if (semesterSubjects != null && currentChapelManager != null) {
      final nextChapelManager = currentChapelManager.copyWith(data: currentChapelManager.data.also((it) {
        it[yearSemester] = semesterSubjects;
      }));
      await _localStorageChapelManagerPort.saveChapelManager(nextChapelManager);
      _streamController.add(nextChapelManager);
      return true;
    }
    return false;
  }

  @override
  Future<bool> loadNewChapelManager() async {
    final semesterSubjectsManager = await _localStorageSemesterSubjectsManagerPort.retrieveSemesterSubjectsManager();
    if (semesterSubjectsManager == null) {
      return false;
    }

    final chapelManager = await _externalChapelManagerRetrievalPort
        .retrieveChapels(semesterSubjectsManager.data.values
            .where((semesterSubjects) {
              return semesterSubjects.subjects.values.any((subject) {
                return subject.category == "채플" || ["CHAPEL", "비전채플"].contains(subject.name);
              });
            })
            .map((semesterSubjects) => semesterSubjects.currentSemester)
            .toList())
        .result
        .then((res) => ChapelManager(SplayTreeMap.fromIterable(
              res,
              key: (chapel) => chapel.currentSemester,
            )));

    await _localStorageChapelManagerPort.saveChapelManager(chapelManager);
    _streamController.add(chapelManager);
    return true;
  }

  @override
  Future<bool> changeOverwrittenAttendance(YearSemester yearSemester, ChapelAttendance attendance, ChapelAttendanceStatus newOverwrittenStatus) async {
    final currentChapelManager = await getChapelManager();
    if (currentChapelManager == null) {
      return false;
    }

    if (currentChapelManager.data[yearSemester] == null) {
      return false;
    }

    if (currentChapelManager.data[yearSemester]!.attendances[attendance.lectureDate] == null) {
      return false;
    }

    final nextChapelManager = currentChapelManager.copyWith(data: currentChapelManager.data.also((it) {
      it[yearSemester] = it[yearSemester]!.copyWith(
          attendances: it[yearSemester]!.attendances.also((it) {
        it[attendance.lectureDate] = it[attendance.lectureDate]!.copyWith(overwrittenStatus: newOverwrittenStatus);
      }));
    }));

    await _localStorageChapelManagerPort.saveChapelManager(nextChapelManager);
    _streamController.add(nextChapelManager);
    return true;
  }

  @override
  Future<void> clearChapelManager() async {
    final chapelManager = ChapelManager.empty();
    await _localStorageChapelManagerPort.saveChapelManager(chapelManager);
    _streamController.add(chapelManager);
  }

  @override
  Stream<ChapelManager> getChapelManagerStream() {
    return _streamController.stream.asBroadcastStream();
  }

  @override
  Future<void> showToast(String message) async {
    await _toastPort.showToast(message);
  }
}
