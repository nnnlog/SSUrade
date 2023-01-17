import 'package:ssurade/types/Semester.dart';
import 'package:quiver/core.dart';

class YearSemester extends Comparable<YearSemester> {
  int year;
  Semester semester;

  YearSemester(this.year, this.semester);

  @override
  String toString() => "$runtimeType(year=$year, semester=$semester)";

  @override
  int get hashCode => hash2(year.hashCode, semester.hashCode);

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }

  bool operator <(YearSemester other) {
    // if (other is YearSemester) {
    return year == other.year ? semester.webIndex < other.semester.webIndex : year < other.year;
    // }
    // throw Exception("Only support for YearSemester");
  }

  String toKey() => "$year:${semester.name}";

  static YearSemester fromKey(String key) {
    int index = key.indexOf(":");
    int year = int.parse(key.substring(0, index));
    String semester = key.substring(index + 1);
    return YearSemester(year, Semester.parse(semester));
  }

  static YearSemester now() {
    var time = DateTime.now();
    if (time.month <= 2) {
      return YearSemester(time.year - 1, Semester.second);
    } else if (time.month <= 8) {
      return YearSemester(time.year, Semester.first);
    } else {
      return YearSemester(time.year, Semester.second);
    }
  }

  @override
  int compareTo(YearSemester other) {
    if (this == other) return 0;
    return this < other ? -1 : 1;
  }
}
