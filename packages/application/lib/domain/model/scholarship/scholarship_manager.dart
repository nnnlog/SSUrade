import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade_application/domain/model/scholarship/scholarship.dart';

part 'scholarship_manager.g.dart';

@CopyWith()
@JsonSerializable()
class ScholarshipManager extends Equatable {
  @JsonKey()
  final List<Scholarship> data;

  const ScholarshipManager(this.data);

  const ScholarshipManager.empty() : data = const [];

  @override
  List<Object?> get props => [data];

  factory ScholarshipManager.fromJson(Map<String, dynamic> json) => _$ScholarshipManagerFromJson(json);

  Map<String, dynamic> toJson() => _$ScholarshipManagerToJson(this);

  bool get isEmpty => data.isEmpty;

  bool get isNotEmpty => data.isNotEmpty;
}
