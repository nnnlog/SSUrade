import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'absent_application.g.dart';

@CopyWith()
@JsonSerializable()
class AbsentApplication extends Equatable {
  @JsonKey()
  final String absentType;
  @JsonKey()
  final String startDate;
  @JsonKey()
  final String endDate;
  @JsonKey()
  final String absentCause;
  @JsonKey()
  final String applicationDate;
  @JsonKey()
  final String proceedDate;
  @JsonKey()
  final String rejectCause;
  @JsonKey()
  final String status;

  const AbsentApplication({
    required this.absentType,
    required this.startDate,
    required this.endDate,
    required this.absentCause,
    required this.applicationDate,
    required this.proceedDate,
    required this.rejectCause,
    required this.status,
  });

  @override
  List<Object?> get props => [absentType, startDate, endDate, absentCause, applicationDate, proceedDate, rejectCause, status];

  // JSON serialization
  factory AbsentApplication.fromJson(Map<String, dynamic> json) => _$AbsentApplicationFromJson(json);

  Map<String, dynamic> toJson() => _$AbsentApplicationToJson(this);
}
