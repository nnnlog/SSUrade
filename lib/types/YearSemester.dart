import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/core.dart';
import 'package:ssurade/types/Semester.dart';

part 'YearSemester.g.dart';

@JsonSerializable()
class YearSemester extends Comparable<YearSemester> {
  @JsonKey()
  int year;
  @JsonKey()
  Semester semester;

  YearSemester(this.year, this.semester);

  factory YearSemester.fromJson(Map<String, dynamic> json) => _$YearSemesterFromJson(json);

  Map<String, dynamic> toJson() => _$YearSemesterToJson(this);

  @override
  String toString() => "$runtimeType(year=$year, semester=$semester)";

  @override
  int get hashCode => hash2(year.hashCode, semester.hashCode);

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }

  bool operator <(YearSemester other) {
    return year == other.year ? semester.webIndex < other.semester.webIndex : year < other.year;
  }

  @override
  int compareTo(YearSemester other) {
    if (this == other) return 0;
    return this < other ? -1 : 1;
  }
}
