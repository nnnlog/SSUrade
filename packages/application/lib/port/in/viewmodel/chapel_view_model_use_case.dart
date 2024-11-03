import 'package:ssurade_application/domain/model/chapel/chapel_attendance.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_attendance_status.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_manager.dart';
import 'package:ssurade_application/domain/model/semester/year_semester.dart';

abstract interface class ChapelViewModelUseCase {
  Future<ChapelManager?> getChapelManager();

  Future<bool> loadNewChapel(YearSemester yearSemester);

  Future<bool> loadNewChapelManager();

  Future<bool> changeOverwrittenAttendance(YearSemester yearSemester, ChapelAttendance attendance, ChapelAttendanceStatus newOverwrittenStatus);

  Future<void> clearChapelManager();

  Stream<ChapelManager> getChapelManagerStream();

  Future<void> showToast(String message);
}
