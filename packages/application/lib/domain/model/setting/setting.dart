import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'setting.g.dart';

@CopyWith()
@JsonSerializable()
class Setting extends Equatable {
  @JsonKey()
  final bool refreshInformationAutomatically;
  @JsonKey()
  final bool enableBackgroundFeature;
  @JsonKey()
  final bool showGradeInBackground;
  @JsonKey()
  final int backgroundInterval;
  @JsonKey()
  final bool agree;

  const Setting({
    required this.refreshInformationAutomatically,
    required this.enableBackgroundFeature,
    required this.showGradeInBackground,
    required this.backgroundInterval,
    required this.agree,
  });

  @override
  List<Object?> get props => [refreshInformationAutomatically, enableBackgroundFeature, showGradeInBackground, backgroundInterval, agree];

  factory Setting.defaultSetting() => Setting(
        refreshInformationAutomatically: false,
        enableBackgroundFeature: true,
        showGradeInBackground: true,
        backgroundInterval: 15,
        agree: false,
      );

  // JSON serialization
  factory Setting.fromJson(Map<String, dynamic> json) => _$SettingFromJson(json);

  Map<String, dynamic> toJson() => _$SettingToJson(this);
}
