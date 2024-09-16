import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

// import 'package:ssurade_application/domain/model/filesystem/filesystem.dart';

part 'background_setting.g.dart';

@CopyWith()
@JsonSerializable()
class BackgroundSetting extends Equatable {
  @JsonKey()
  final int notificationId;

  const BackgroundSetting(this.notificationId);

  @override
  List<Object?> get props => [notificationId];

  factory BackgroundSetting.empty() => BackgroundSetting(0);

  // JSON serialization

  factory BackgroundSetting.fromJson(Map<String, dynamic> json) => _$BackgroundSettingFromJson(json);

  Map<String, dynamic> toJson() => _$BackgroundSettingToJson(this);
}
