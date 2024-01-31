import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade/types/semester/year_semester.dart';

part 'scholarship.g.dart';

@JsonSerializable()
class Scholarship {
  @JsonKey()
  YearSemester when; // 장학 처리 시기
  @JsonKey()
  String name; // 장학금명
  @JsonKey()
  String process; // 처리상태
  @JsonKey()
  String price; // 선발금액

  Scholarship(this.when, this.name, this.process, this.price);

  factory Scholarship.fromJson(Map<String, dynamic> json) => _$ScholarshipFromJson(json);

  Map<String, dynamic> toJson() => _$ScholarshipToJson(this);

  @override
  String toString() {
    return "$runtimeType(when=$when, name=$name, process=$process, price=$price)";
  }
}
