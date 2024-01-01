import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade/filesystem/filesystem.dart';

part 'setting.g.dart';

@JsonSerializable()
class Setting {
  @JsonKey()
  bool refreshGradeAutomatically;
  @JsonKey()
  bool noticeGradeInBackground;
  @JsonKey()
  bool showGrade;
  @JsonKey()
  int timeoutGrade;
  @JsonKey()
  int timeoutAllGrade;
  @JsonKey()
  bool agree;

  Setting(this.refreshGradeAutomatically, this.noticeGradeInBackground, this.showGrade, this.timeoutGrade, this.timeoutAllGrade, this.agree);

  factory Setting.fromJson(Map<String, dynamic> json) => _$SettingFromJson(json);

  Map<String, dynamic> toJson() => _$SettingToJson(this);

  static const String _filename = "settings.json"; // internal file name

  static Future<Setting> loadFromFile() async {
    try {
      dynamic json = {};
      if (await existFile(_filename)) {
        json = jsonDecode((await readFile(_filename))!);
      }
      return Setting.fromJson(json);
    } catch (e) {
      return Setting(false, true, true, 20, 60, false);
    }
  }

  saveFile() => writeFile(_filename, jsonEncode(toJson()));

  @override
  String toString() {
    return "$runtimeType(refreshGradeAutomatically=$refreshGradeAutomatically, noticeGradeInBackground=$noticeGradeInBackground, showGrade=$showGrade, timeoutGrade=$timeoutGrade, timeoutAllGrade=$timeoutAllGrade, agree=$agree)";
  }
}
