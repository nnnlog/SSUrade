import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade_application/domain/model/scholarship/scholarship.dart';

part 'scholarship_manager.g.dart';

@JsonSerializable()
class ScholarshipManager {
  @JsonKey()
  final List<Scholarship> data;

  const ScholarshipManager(this.data);

  factory ScholarshipManager.fromJson(Map<String, dynamic> json) => _$ScholarshipManagerFromJson(json);

  Map<String, dynamic> toJson() => _$ScholarshipManagerToJson(this);

  bool get isEmpty => data.isEmpty;

  bool get isNotEmpty => data.isNotEmpty;
}
