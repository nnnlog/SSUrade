import 'dart:collection';

import 'package:ssurade/types/chapel/chapel.dart';
import 'package:ssurade/types/chapel/chapel_attendance.dart';
import 'package:ssurade/types/semester/year_semester.dart';

extension SplayTreeSetExtensionOnChapelInformation on SplayTreeSet<ChapelInformation> {
  ChapelInformation? operator [](YearSemester semester) => lookup(ChapelInformation(semester, SplayTreeSet()));
}

extension SplayTreeSetExtensionOnChapelAttendanceInformation on SplayTreeSet<ChapelAttendanceInformation> {
  ChapelAttendanceInformation? operator [](String lectureDate) => lookup(ChapelAttendanceInformation(lectureDate: lectureDate));
}
