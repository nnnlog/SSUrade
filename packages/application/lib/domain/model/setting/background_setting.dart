import 'package:json_annotation/json_annotation.dart';

// import 'package:ssurade_application/domain/model/filesystem/filesystem.dart';

part 'background_setting.g.dart';

@JsonSerializable()
class BackgroundSetting {
  @JsonKey()
  final int notificationId;

  const BackgroundSetting(this.notificationId);

  factory BackgroundSetting.empty() => BackgroundSetting(0);

  // JSON serialization

  factory BackgroundSetting.fromJson(Map<String, dynamic> json) => _$BackgroundSettingFromJson(json);

  Map<String, dynamic> toJson() => _$BackgroundSettingToJson(this);
}
