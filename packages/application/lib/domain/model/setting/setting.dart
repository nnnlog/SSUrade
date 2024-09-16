import 'package:json_annotation/json_annotation.dart';

part 'setting.g.dart';

@JsonSerializable()
class Setting {
  @JsonKey()
  final bool refreshGradeAutomatically;
  @JsonKey()
  final bool noticeGradeInBackground;
  @JsonKey()
  final bool showGrade;
  @JsonKey()
  final int interval;
  @JsonKey()
  final int timeoutGrade;
  @JsonKey()
  final int timeoutAllGrade;
  @JsonKey()
  final bool agree;

  const Setting({
    required this.refreshGradeAutomatically,
    required this.noticeGradeInBackground,
    required this.showGrade,
    required this.interval,
    required this.timeoutGrade,
    required this.timeoutAllGrade,
    required this.agree,
  });

  factory Setting.defaultSetting() => Setting(
        refreshGradeAutomatically: false,
        noticeGradeInBackground: true,
        showGrade: true,
        interval: 15,
        timeoutGrade: 20,
        timeoutAllGrade: 60,
        agree: false,
      );

  // JSON serialization
  factory Setting.fromJson(Map<String, dynamic> json) => _$SettingFromJson(json);

  Map<String, dynamic> toJson() => _$SettingToJson(this);
}
