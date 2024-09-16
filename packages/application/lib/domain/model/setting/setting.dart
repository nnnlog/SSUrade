import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'setting.g.dart';

@CopyWith()
@JsonSerializable()
class Setting extends Equatable {
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

  @override
  List<Object?> get props => [refreshGradeAutomatically, noticeGradeInBackground, showGrade, interval, timeoutGrade, timeoutAllGrade, agree];

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
