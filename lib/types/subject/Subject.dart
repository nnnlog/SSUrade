import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade/types/subject/gradeTable.dart';

part 'Subject.g.dart';

@JsonSerializable()
class Subject extends Comparable<Subject> {
  @JsonKey(
    includeFromJson: true,
    includeToJson: true,
  )
  String _code; // 과목 번호
  @JsonKey()
  String name; // 과목명
  @JsonKey()
  double credit; // 학점 (이수 단위)
  @JsonKey()
  String grade; // 학점 (성적)
  @JsonKey()
  String score;
  @JsonKey()
  String professor; // 교수명
  @JsonKey()
  String category = ""; // 이수 구분 (전공기초, 전공필수, 전공선택, 교양필수, 교양선택, 채플, 복수전공, 교직, 논문/시험, 일반선택)
  @JsonKey()
  bool isPassFail = false; // P/F 과목 여부
  @JsonKey()
  Map<String, String> detail = Map();

  Subject(this._code, this.name, this.credit, this.grade, this.score, this.professor, this.category, this.isPassFail);

  String get code => _code;

  factory Subject.fromJson(Map<String, dynamic> json) => _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);

  bool get isMajor => category.startsWith("전공");

  Subject merge(Subject other) {
    // 학기별 성적 조회 페이지
    if (other.name.isNotEmpty) name = other.name;
    if (other.professor.isNotEmpty) professor = other.professor;
    if (other.grade.isNotEmpty) grade = other.grade; // 성적 입력 기간

    // 이수구분별 성적 조회 페이지
    if (other.category.isNotEmpty) category = other.category;

    isPassFail |= other.isPassFail;

    return this;
  }

  @override
  String toString() {
    return "$runtimeType(code=$code, name=$name, credit=$credit, grade=$grade, score=$score, professor=$professor, category=$category, isPassFail=$isPassFail, detail=$detail)";
  }

  @override
  int compareTo(Subject other) {
    int x = gradeTable[grade] ?? -5;
    int y = gradeTable[other.grade] ?? -5;
    if (x != y) return x > y ? -1 : 1; // 성적(grade) 높은 것부터
    if (credit != other.credit) return credit > other.credit ? -1 : 1; // 학점(credit) 높은 것부터
    return name.compareTo(other.name);
  }
}
