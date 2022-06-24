import 'package:quiver/core.dart';

enum Semester {
  first,
  summer,
  second,
  winter;

  static Semester parse(String str) {
    str = str.replaceAll(" ", "");
    for (var semester in Semester.values) {
      if (str == semester.name) {
        return semester;
      }
    }

    throw Exception("Unknown semester, got $str");
  }
}

extension SemesterExtension on Semester {
  String get name {
    switch (this) {
      case Semester.first:
        return "1학기";
      case Semester.summer:
        return "여름학기";
      case Semester.second:
        return "2학기";
      case Semester.winter:
        return "겨울학기";
    }
  }

  int get webIndex {
    switch (this) {
      case Semester.first:
        return 1;
      case Semester.summer:
        return 2;
      case Semester.second:
        return 3;
      case Semester.winter:
        return 4;
    }
  }
}

class YearSemester {
  String year;
  Semester semester;

  YearSemester(this.year, this.semester);

  @override
  String toString() => "YearSemester(year=$year, semester=$semester)";

  @override
  int get hashCode => hash2(year.hashCode, semester.hashCode);

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }
}
