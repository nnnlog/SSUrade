import 'dart:collection';

import 'package:ssurade/types/chapel/ChapelAttendanceInformation.dart';
import 'package:ssurade/types/chapel/ChapelInformation.dart';
import 'package:ssurade/types/semester/YearSemester.dart';

extension SplayTreeSetExtensionOnChapelInformation on SplayTreeSet<ChapelInformation> {
  ChapelInformation? operator [](YearSemester semester) => lookup(ChapelInformation(semester, SplayTreeSet()));
}

extension SplayTreeSetExtensionOnChapelAttendanceInformation on SplayTreeSet<ChapelAttendanceInformation> {
  ChapelAttendanceInformation? operator [](String lectureDate) => lookup(ChapelAttendanceInformation(lectureDate: lectureDate));
}
