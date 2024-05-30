import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade/types/subject/grade_table.dart';
import 'package:ssurade/types/subject/state.dart';

part 'subject.g.dart';

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
  String info; // 졸업 사정 제외 사유
  @JsonKey()
  Map<String, String> detail = {};

  Subject(this._code, this.name, this.credit, this.grade, this.score, this.professor, this.category, this.isPassFail, this.info);

  String get code => _code;

  factory Subject.fromJson(Map<String, dynamic> json) => _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);

  bool get isMajor => category.startsWith("전공") && category != "전공기초";

  bool get isExcluded => info.split(",").indexWhere((element) => element.startsWith("Ex")) > -1;

  @override
  String toString() {
    return "$runtimeType(code=$code, name=$name, credit=$credit, grade=$grade, score=$score, professor=$professor, category=$category, isPassFail=$isPassFail, info=$info, detail=$detail)";
  }

  @override
  int compareTo(Subject other) {
    int x = gradeTable[grade] ?? -5;
    int y = gradeTable[other.grade] ?? -5;
    if (x != y) return x > y ? -1 : 1; // 성적(grade) 높은 것부터
    if (credit != other.credit) return credit > other.credit ? -1 : 1; // 학점(credit) 높은 것부터
    return name.compareTo(other.name);
  }

  static Subject? merge(Subject after, Subject before, int stateAfter, int stateBefore) {
    if (stateAfter | stateBefore != STATE_FULL) return null;

    // 성적 상세 조회
    if (after.detail.isEmpty) after.detail = before.detail;

    if (stateAfter == STATE_FULL) return after;

    // 이수구분별 성적 조회
    if ((stateAfter & STATE_CATEGORY > 0) && (stateBefore & STATE_SEMESTER > 0)) {
      if (after.name.isEmpty) after.name = before.name;
      if (after.professor.isEmpty) after.professor = before.professor;
      if (after.grade.isEmpty) after.grade = before.grade; // 성적 입력 기간
      if (after.score.isEmpty) after.score = before.score; // Pass 과목
    }

    // 학기별 성적 조회
    if ((stateAfter & STATE_SEMESTER > 0) && (STATE_CATEGORY & STATE_CATEGORY > 0)) {
      if (after.category.isEmpty) after.category = before.category;
      after.isPassFail = before.isPassFail;
      after.info = before.info;
      after.credit = before.credit; // 성적 미입력 기간 (이수구분별 성적표 우선)
    }

    return after;
  }
}
