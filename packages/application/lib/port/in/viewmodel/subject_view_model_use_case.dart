import 'dart:typed_data';

import 'package:ssurade_application/domain/model/semester/year_semester.dart';
import 'package:ssurade_application/domain/model/subject/semester_subjects_manager.dart';

abstract interface class SubjectViewModelUseCase {
  Future<SemesterSubjectsManager?> getSemesterSubjectsManager();

  Future<bool> loadNewSemesterSubjects(YearSemester yearSemester);

  Future<bool> loadNewSemesterSubjectsManager();

  Future<void> clearSemesterSubjectsManager();

  Stream<SemesterSubjectsManager> getSemesterSubjectsManagerStream();

  Future<void> saveScreenshotInGallery({required Uint8List data, required String name});

  Future<void> showToast(String message);
}
