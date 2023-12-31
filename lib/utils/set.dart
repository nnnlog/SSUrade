import 'dart:collection';

import 'package:ssurade/types/chapel/ChapelInformation.dart';
import 'package:ssurade/types/semester/YearSemester.dart';

extension SplayTreeSetExtensionOnChapelInformation on SplayTreeSet<ChapelInformation> {
  operator [](YearSemester semester) => lookup(ChapelInformation(semester, SplayTreeSet()));
}
