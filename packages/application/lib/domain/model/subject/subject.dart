import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade_application/domain/model/subject/grade_table.dart';
import 'package:ssurade_application/domain/model/subject/state.dart';

part 'subject.g.dart';

@CopyWith()
@JsonSerializable()
class Subject extends Equatable implements Comparable<Subject> {
  @JsonKey()
  final String code; // 과목 번호
  @JsonKey()
  final String name; // 과목명
  @JsonKey()
  final double credit; // 학점 (이수 단위)
  @JsonKey()
  final String grade; // 학점 (성적)
  @JsonKey()
  final String score;
  @JsonKey()
  final String professor; // 교수명
  @JsonKey()
  final String category; // 이수 구분 (전공기초, 전공필수, 전공선택, 교양필수, 교양선택, 채플, 복수전공, 교직, 논문/시험, 일반선택)
  @JsonKey()
  final bool isPassFail; // P/F 과목 여부
  @JsonKey()
  final String info; // 졸업 사정 제외 사유
  @JsonKey()
  final Map<String, String> detail;

  const Subject({
    required this.code,
    required this.name,
    required this.credit,
    required this.grade,
    required this.score,
    required this.professor,
    required this.category,
    required this.isPassFail,
    required this.info,
    required this.detail,
  });

  factory Subject.fromJson(Map<String, dynamic> json) => _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);

  // 주전공 과목 여부
  bool get isMajor => category.startsWith("전공") && category != "전공기초";

  // 졸업 사정 제외 과목 여부
  bool get excluded => grade.trim() == "" || info.split(",").indexWhere((element) => element.startsWith("Ex")) > -1;

  @override
  int compareTo(Subject other) {
    int x = GradeTable.scores[grade] ?? -5;
    int y = GradeTable.scores[other.grade] ?? -5;
    if (x != y) return x > y ? -1 : 1; // 성적(grade) 높은 것부터
    if (credit != other.credit) return credit > other.credit ? -1 : 1; // 학점(credit) 높은 것부터
    return name.compareTo(other.name);
  }

  @override
  List<Object?> get props => [code, name, credit, grade, score, professor, category, isPassFail, info, detail];

  static Subject? merge(Subject after, Subject before, int stateAfter, int stateBefore) {
    if ((stateAfter | stateBefore) != SubjectState.full) return null;

    if (stateAfter == SubjectState.full) return after;

    // 이수구분별 성적 조회 <- 학기별 성적 조회
    if ((stateAfter & SubjectState.category > 0) && (stateBefore & SubjectState.semester > 0)) {
      return after.copyWith(
        name: before.name.isEmpty ? after.name : before.name,
        professor: before.professor.isEmpty ? after.professor : before.professor,
        grade: before.grade.isEmpty ? after.grade : before.grade,
        score: before.score.isEmpty ? after.score : before.score,
        detail: before.detail.isEmpty ? after.detail : before.detail,
      );
    }

    // 학기별 성적 조회 <- 이수구분별 성적 조회
    if ((stateAfter & SubjectState.semester > 0) && (stateBefore & SubjectState.category > 0)) {
      return after.copyWith(
        category: before.category.isEmpty ? after.category : before.category,
        isPassFail: before.isPassFail ? after.isPassFail : before.isPassFail,
        info: before.info.isEmpty ? after.info : before.info,
        credit: before.credit == 0 ? after.credit : before.credit,
      );
    }

    return null;
  }
}
