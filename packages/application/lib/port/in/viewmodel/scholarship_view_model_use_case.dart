import 'dart:typed_data';

import 'package:ssurade_application/domain/model/chapel/chapel_attendance.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_attendance_status.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_manager.dart';
import 'package:ssurade_application/domain/model/scholarship/scholarship_manager.dart';
import 'package:ssurade_application/domain/model/semester/year_semester.dart';
import 'package:ssurade_application/domain/model/subject/semester_subjects_manager.dart';

abstract interface class ScholarshipViewModelUseCase {
  Future<ScholarshipManager?> getScholarshipManager();

  Future<bool> loadNewScholarshipManager();

  Future<void> clearScholarshipManager();

  Stream<ScholarshipManager> getScholarshipManagerStream();

  Future<void> showToast(String message);
}
