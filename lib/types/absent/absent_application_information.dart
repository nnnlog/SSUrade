import 'package:json_annotation/json_annotation.dart';

part 'absent_application_information.g.dart';

@JsonSerializable()
class AbsentApplicationInformation {
  @JsonKey()
  String absentType;
  @JsonKey()
  String startDate;
  @JsonKey()
  String endDate;
  @JsonKey()
  String absentCause;
  @JsonKey()
  String applicationDate;
  @JsonKey()
  String proceedDate;
  @JsonKey()
  String rejectCause;
  @JsonKey()
  String status;

  AbsentApplicationInformation(
    this.absentType,
    this.startDate,
    this.endDate,
    this.absentCause,
    this.applicationDate,
    this.proceedDate,
    this.rejectCause,
    this.status,
  );

  factory AbsentApplicationInformation.fromJson(Map<String, dynamic> json) => _$AbsentApplicationInformationFromJson(json);

  Map<String, dynamic> toJson() => _$AbsentApplicationInformationToJson(this);

  @override
  String toString() {
    return "$runtimeType(absentType=$absentType, startDate=$startDate, endDate=$endDate, absentCause=$absentCause, applicationDate=$applicationDate, proceedDate=$proceedDate, rejectCause=$rejectCause, status=$status)";
  }
}
