import 'package:json_annotation/json_annotation.dart';
// import 'package:quiver/core.dart';
import 'package:ssurade_application/domain/model/semester/semester.dart';

part 'year_semester.g.dart';

@JsonSerializable()
class YearSemester implements Comparable<YearSemester> {
  @JsonKey()
  final int year;
  @JsonKey()
  final Semester semester;

  const YearSemester({
    required this.year,
    required this.semester,
  });

  factory YearSemester.fromJson(Map<String, dynamic> json) => _$YearSemesterFromJson(json);

  Map<String, dynamic> toJson() => _$YearSemesterToJson(this);

  get display => "$year-${semester.displayName}";

  bool operator <(YearSemester other) {
    const Map<Semester, int> semesterOrder = {
      Semester.first: 0,
      Semester.summer: 1,
      Semester.second: 2,
      Semester.winter: 3,
    };

    return year == other.year ? semesterOrder[semester]! < semesterOrder[semester]! : year < other.year;
  }

  @override
  int compareTo(YearSemester other) {
    if (this == other) return 0;
    return this < other ? -1 : 1;
  }
}
