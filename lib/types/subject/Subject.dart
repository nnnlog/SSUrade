import 'package:json_annotation/json_annotation.dart';

part 'Subject.g.dart';

@JsonSerializable()
class Subject {
  @JsonKey()
  String code; // 과목 번호
  @JsonKey()
  String name; // 과목명
  @JsonKey()
  double credit; // 학점 (이수 단위)
  @JsonKey()
  String grade; // 학점 (성적)
  @JsonKey()
  String professor; // 교수명

  // late String category; // 이수 구분 (전공기초, 전공필수, 전공선택, 교양필수, 교양선택, 채플 등)
  // late bool pf = false; // P/F 과목 여부

  Subject(this.code, this.name, this.credit, this.grade, this.professor);

  factory Subject.fromJson(Map<String, dynamic> json) => _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);

  @override
  String toString() {
    return "$runtimeType(code=$code, name=$name, credit=$credit, grade=$grade, professor=$professor)";
  }
}
