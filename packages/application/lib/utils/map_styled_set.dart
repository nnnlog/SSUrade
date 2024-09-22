import 'dart:collection';

import 'package:ssurade_application/domain/model/chapel/chapel.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_attendance.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_attendance_status.dart';
import 'package:ssurade_application/domain/model/semester/year_semester.dart';

extension SplayTreeSetExtensionOnChapel on SplayTreeSet<Chapel> {
  Chapel? operator [](YearSemester semester) => lookup(Chapel(
        currentSemester: semester,
        attendances: SplayTreeSet(),
        subjectCode: '',
        subjectPlace: '',
        subjectTime: '',
        floor: '',
        seatNo: '',
      ));
}

extension SplayTreeSetExtensionOnChapelAttendance on SplayTreeSet<ChapelAttendance> {
  ChapelAttendance? operator [](String lectureDate) => lookup(ChapelAttendance(
        status: ChapelAttendanceStatus.unknown,
        overwrittenStatus: ChapelAttendanceStatus.unknown,
        affiliation: '',
        lectureDate: lectureDate,
        lectureEtc: '',
        lectureName: '',
        lectureType: '',
        lecturer: '',
      ));
}
