import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade_application/domain/model/semester/year_semester.dart';

part 'scholarship.g.dart';

@CopyWith()
@JsonSerializable()
class Scholarship extends Equatable {
  @JsonKey()
  final YearSemester when; // 장학 처리 시기
  @JsonKey()
  final String name; // 장학금명
  @JsonKey()
  final String process; // 처리상태
  @JsonKey()
  final String price; // 선발금액

  const Scholarship({
    required this.when,
    required this.name,
    required this.process,
    required this.price,
  });

  @override
  List<Object?> get props => [when, name, process, price];

  factory Scholarship.fromJson(Map<String, dynamic> json) => _$ScholarshipFromJson(json);

  Map<String, dynamic> toJson() => _$ScholarshipToJson(this);
}
