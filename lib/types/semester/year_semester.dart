import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/core.dart';
import 'package:ssurade/types/semester/semester.dart';

part 'year_semester.g.dart';

@JsonSerializable()
class YearSemester with Comparable<YearSemester> {
  @JsonKey(
    includeToJson: true,
    includeFromJson: true,
  )
  final int _year;
  @JsonKey(
    includeToJson: true,
    includeFromJson: true,
  )
  final Semester _semester;

  const YearSemester(this._year, this._semester);

  factory YearSemester.fromJson(Map<String, dynamic> json) => _$YearSemesterFromJson(json);

  Map<String, dynamic> toJson() => _$YearSemesterToJson(this);

  get year => _year;

  Semester get semester => _semester;

  @override
  String toString() => "$runtimeType(year=$year, semester=$semester)";

  get display => "$year-${semester.displayName}";

  @override
  int get hashCode => hash2(year.hashCode, semester.hashCode);

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }

  bool operator <(YearSemester other) {
    return year == other.year ? int.parse(semester.keyValue) < int.parse(other.semester.keyValue) : year < other.year;
  }

  @override
  int compareTo(YearSemester other) {
    if (this == other) return 0;
    return this < other ? -1 : 1;
  }
}
