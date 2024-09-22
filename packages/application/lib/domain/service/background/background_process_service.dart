import 'dart:collection';
import 'dart:math';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:mutex/mutex.dart';
import 'package:ssurade_application/domain/model/chapel/chapel.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_attendance.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_attendance_status.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_manager.dart';
import 'package:ssurade_application/domain/model/semester/semester.dart';
import 'package:ssurade_application/domain/model/semester/year_semester.dart';
import 'package:ssurade_application/domain/model/subject/semester_subjects.dart';
import 'package:ssurade_application/domain/model/subject/semester_subjects_manager.dart';
import 'package:ssurade_application/port/in/background/background_process_use_case.dart';
import 'package:ssurade_application/port/out/application/app_environment_port.dart';
import 'package:ssurade_application/port/out/application/notification_port.dart';
import 'package:ssurade_application/port/out/external/external_absent_application_retrieval_port.dart';
import 'package:ssurade_application/port/out/external/external_chapel_retrieval_port.dart';
import 'package:ssurade_application/port/out/external/external_scholarship_manager_retrieval_port.dart';
import 'package:ssurade_application/port/out/external/external_subject_retrieval_port.dart';
import 'package:ssurade_application/port/out/local_storage/retrieval/local_storage_absent_application_manager_retrieval_port.dart';
import 'package:ssurade_application/port/out/local_storage/retrieval/local_storage_chapel_manager_retrieval_port.dart';
import 'package:ssurade_application/port/out/local_storage/retrieval/local_storage_scholarship_manager_retrieval_port.dart';
import 'package:ssurade_application/port/out/local_storage/retrieval/local_storage_semester_subjects_manager_retrieval_port.dart';
import 'package:ssurade_application/port/out/local_storage/retrieval/local_storage_setting_retrieval_port.dart';
import 'package:ssurade_application/port/out/local_storage/save/local_storage_absent_application_manager_save_port.dart';
import 'package:ssurade_application/port/out/local_storage/save/local_storage_chapel_manager_save_port.dart';
import 'package:ssurade_application/port/out/local_storage/save/local_storage_scholarship_manager_save_port.dart';
import 'package:ssurade_application/port/out/local_storage/save/local_storage_semester_subjects_manager_save_port.dart';
import 'package:ssurade_application/utils/map_styled_set.dart';

@Singleton(as: BackgroundProcessUseCase)
class BackgroundProcessService implements BackgroundProcessUseCase {
  final LocalStorageAbsentApplicationManagerRetrievalPort _localStorageAbsentApplicationManagerRetrievalPort;
  final LocalStorageAbsentApplicationManagerSavePort _localStorageAbsentApplicationManagerSavePort;
  final ExternalAbsentApplicationRetrievalPort _externalAbsentApplicationRetrievalPort;

  final LocalStorageChapelManagerRetrievalPort _localStorageChapelManagerRetrievalPort;
  final LocalStorageChapelManagerSavePort _localStorageChapelManagerSavePort;
  final ExternalChapelManagerRetrievalPort _externalChapelRetrievalPort;

  final LocalStorageSemesterSubjectsManagerRetrievalPort _localStorageSemesterSubjectsManagerRetrievalPort;
  final LocalStorageSemesterSubjectsManagerSavePort _localStorageSemesterSubjectsManagerSavePort;
  final ExternalSubjectRetrievalPort _externalSubjectRetrievalPort;

  final LocalStorageScholarshipManagerRetrievalPort _localStorageScholarshipManagerRetrievalPort;
  final LocalStorageScholarshipManagerSavePort _localStorageScholarshipManagerSavePort;
  final ExternalScholarshipManagerRetrievalPort _externalScholarshipRetrievalPort;

  final LocalStorageSettingRetrievalPort _localStorageSettingRetrievalPort;

  final NotificationPort _notificationPort;

  final AppEnvironmentPort _appEnvironmentPort;

  final Mutex _mutexForChapel = Mutex();

  BackgroundProcessService(
    this._localStorageAbsentApplicationManagerRetrievalPort,
    this._localStorageAbsentApplicationManagerSavePort,
    this._externalAbsentApplicationRetrievalPort,
    this._localStorageChapelManagerRetrievalPort,
    this._localStorageChapelManagerSavePort,
    this._externalChapelRetrievalPort,
    this._localStorageSemesterSubjectsManagerRetrievalPort,
    this._localStorageSemesterSubjectsManagerSavePort,
    this._externalSubjectRetrievalPort,
    this._localStorageScholarshipManagerRetrievalPort,
    this._localStorageScholarshipManagerSavePort,
    this._externalScholarshipRetrievalPort,
    this._localStorageSettingRetrievalPort,
    this._notificationPort,
    this._appEnvironmentPort,
  );

  @override
  Future<void> fetchAbsent() async {
    final originalAbsentData = await _localStorageAbsentApplicationManagerRetrievalPort.retrieveAbsentApplicationManager();

    if (originalAbsentData == null) {
      return;
    }

    final newAbsentData = await _externalAbsentApplicationRetrievalPort.retrieveAbsentManager().result;

    if (newAbsentData == null) {
      return;
    }

    List<String> updates = [];
    for (final data in newAbsentData.data) {
      if (originalAbsentData.data.contains(data)) {
        continue;
      }

      updates.add("${data.startDate == data.endDate ? data.startDate : "${data.startDate} ~ ${data.endDate}"} > ${data.status}");
    }

    if (updates.isNotEmpty) {
      await _notificationPort.sendNotification(title: "유고 결석 정보 변경", body: updates.join("\n"));
      await _localStorageAbsentApplicationManagerSavePort.saveAbsentApplicationManager(newAbsentData);
    } else if (_appEnvironmentPort.getEnvironment() == AppEnvironment.debug) {
      await _notificationPort.sendNotification(title: "not updated (${DateTime.now().toString()})", body: newAbsentData.data.map((e) => "${e.startDate} ~ ${e.endDate} : ${e.status}").join("\n"));
    }
  }

  @override
  Future<void> fetchChapel() async {
    await _mutexForChapel.acquire();

    final originChapelManager = await _localStorageChapelManagerRetrievalPort.retrieveChapelManager();

    if (originChapelManager == null || originChapelManager.data.isEmpty) {
      return;
    }

    final originalChapelData = originChapelManager.data.last;

    final newChapelData = await _externalChapelRetrievalPort.retrieveChapel(originalChapelData.currentSemester).result;

    if (newChapelData == null) {
      return;
    }

    final List<String> updates = [];
    final SplayTreeSet<ChapelAttendance> attendances = SplayTreeSet(); // copy
    for (final attendance in newChapelData.attendances) {
      if (attendance.status == ChapelAttendanceStatus.unknown && originalChapelData.attendances.contains(attendance)) {
        attendances.add(attendance.copyWith(
          overwrittenStatus: originalChapelData.attendances[attendance.lectureDate]!.overwrittenStatus,
        ));
        continue;
      }

      if (attendance.status == ChapelAttendanceStatus.unknown || originalChapelData.attendances[attendance.lectureDate] == attendance) {
        continue;
      }

      updates.add("${attendance.lectureDate} > ${attendance.status.displayText}");
      attendances.add(attendance);
    }

    if (updates.isNotEmpty) {
      await _notificationPort.sendNotification(title: "채플 출결 변경", body: updates.join("\n"));

      final nextChapelData = newChapelData.copyWith(attendances: attendances);

      final nextChapels = SplayTreeSet<Chapel>.from(originChapelManager.data);
      nextChapels.removeWhere((element) => element.currentSemester == newChapelData.currentSemester);
      nextChapels.add(nextChapelData);

      final nextChapelManager = originChapelManager.copyWith(data: nextChapels);

      await _localStorageChapelManagerSavePort.saveChapelManager(nextChapelManager);
    } else if (_appEnvironmentPort.getEnvironment() == AppEnvironment.debug) {
      await _notificationPort.sendNotification(
          title: "not updated (${DateTime.now().toString()})", body: newChapelData.attendances.map((e) => "${e.lectureDate} : ${e.status.displayText}").join("\n"));
    }

    _mutexForChapel.release();
  }

  @override
  Future<void> fetchGrade() async {
    final originalSemesterSubjectsManager = await _localStorageSemesterSubjectsManagerRetrievalPort.retrieveSemesterSubjectsManager();
    final setting = await _localStorageSettingRetrievalPort.retrieveSetting();

    if (originalSemesterSubjectsManager == null) {
      return;
    }

    if (setting == null) {
      return;
    }

    final searches = (originalSemesterSubjectsManager.data.keys.toList()..sort()).sublist(
      max(0, originalSemesterSubjectsManager.data.length - 2),
    ); // 최근 2개 학기 (정규 학기 성적 입력 기간 중 계절 학기 성적이 보이는 이슈가 있음)

    final updates = <String>[];
    final SplayTreeMap<YearSemester, SemesterSubjects> nextData = SplayTreeMap();
    final newSubjects = <SemesterSubjects>[];

    for (final search in searches) {
      final originalSubjects = originalSemesterSubjectsManager.data[search]!;

      final subjects = await _externalSubjectRetrievalPort.retrieveSemesterSubjects(search).result;

      if (subjects == null) {
        continue;
      }

      newSubjects.add(subjects);
      nextData[search] = subjects;

      for (final subject in subjects.subjects.values) {
        if (subject.grade.isEmpty || originalSubjects.subjects[subject.code]?.grade == subject.grade) {
          continue;
        }

        if (setting.showGrade) {
          updates.add("${subject.name} > ${subject.grade}");
        } else {
          updates.add(subject.name);
        }
      }
    }

    originalSemesterSubjectsManager.data.keys.forEach((semester) {
      nextData.putIfAbsent(semester, () => originalSemesterSubjectsManager.data[semester]!);
    });

    if (updates.isNotEmpty) {
      await _notificationPort.sendNotification(title: "성적 정보 변경", body: updates.join("\n"));

      final nextSemesterSubjectsManager = originalSemesterSubjectsManager.copyWith(data: nextData);

      await _localStorageSemesterSubjectsManagerSavePort.saveSemesterSubjectsManager(nextSemesterSubjectsManager);
    } else if (_appEnvironmentPort.getEnvironment() == AppEnvironment.debug) {
      await _notificationPort.sendNotification(title: "not updated (${DateTime.now().toString()})", body: newSubjects.join("\n"));
    }
  }

  @override
  Future<void> fetchNewChapel() async {
    await _mutexForChapel.acquire();

    final search = <YearSemester>[];
    DateTime.now().year.let((it) {
      search.add(YearSemester(year: it, semester: Semester.first));
      search.add(YearSemester(year: it, semester: Semester.second));
    });

    final originalChapelManager = await _localStorageChapelManagerRetrievalPort.retrieveChapelManager() ?? ChapelManager.empty();

    final chapelData = await _externalChapelRetrievalPort.retrieveChapels(search).result;
    List<String> updates = [];
    final List<Chapel> newChapelData = [];

    for (final data in chapelData) {
      if (originalChapelManager.data.contains(data)) {
        continue;
      }

      updates.add(data.currentSemester.displayText);
      newChapelData.add(data);
    }

    if (updates.isNotEmpty) {
      await _notificationPort.sendNotification(title: "채플 정보 등록", body: updates.join("\n"));

      final nextChapels = SplayTreeSet<Chapel>.from(originalChapelManager.data);
      nextChapels.addAll(newChapelData);

      final nextChapelManager = originalChapelManager.copyWith(data: nextChapels);

      await _localStorageChapelManagerSavePort.saveChapelManager(nextChapelManager);
    } else if (_appEnvironmentPort.getEnvironment() == AppEnvironment.debug) {
      await _notificationPort.sendNotification(title: "not updated (${DateTime.now().toString()})", body: chapelData.map((e) => "${e.currentSemester.displayText}").join("\n"));
    }

    _mutexForChapel.release();
  }

  @override
  Future<void> fetchScholarship() async {
    final originalScholarshipManager = await _localStorageScholarshipManagerRetrievalPort.retrieveScholarshipManager();

    if (originalScholarshipManager == null) {
      return;
    }

    final scholarshipData = await _externalScholarshipRetrievalPort.retrieveScholarshipManager().result;

    if (scholarshipData == null) {
      return;
    }

    final originalData = originalScholarshipManager.data;
    final List<String> updates = [];

    for (final data in scholarshipData.data) {
      bool updated = originalData.where((i) {
        return i.when == data.when && i.name == data.name && i.process == data.process && i.price == data.price;
      }).isEmpty;

      if (updated) {
        updates.add("${data.name} > ${data.process} (${data.price}원)");
      }
    }

    if (updates.isNotEmpty) {
      await _notificationPort.sendNotification(title: "장학 정보 변경", body: updates.join("\n"));
      await _localStorageScholarshipManagerSavePort.saveScholarshipManager(scholarshipData);
    } else if (_appEnvironmentPort.getEnvironment() == AppEnvironment.debug) {
      await _notificationPort.sendNotification(title: "not updated (${DateTime.now().toString()})", body: scholarshipData.data.map((e) => "${e.name} : ${e.when.displayText}").join("\n"));
    }
  }
}
