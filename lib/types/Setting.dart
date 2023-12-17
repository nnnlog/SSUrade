import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade/filesystem/FileSystem.dart';

part 'Setting.g.dart';

@JsonSerializable()
class Setting {
  @JsonKey()
  bool refreshGradeAutomatically;
  @JsonKey()
  bool noticeGradeInBackground;
  @JsonKey()
  int timeoutGrade;
  @JsonKey()
  int timeoutAllGrade;
  @JsonKey()
  bool agree;

  Setting(this.refreshGradeAutomatically, this.noticeGradeInBackground, this.timeoutGrade, this.timeoutAllGrade, this.agree);

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
      return Setting(true, true, 20, 60, false);
    }
  }

  saveFile() => writeFile(_filename, jsonEncode(toJson()));

  @override
  String toString() {
    return "$runtimeType(refreshGradeAutomatically=$refreshGradeAutomatically, timeoutGrade=$timeoutGrade, timeoutAllGrade=$timeoutAllGrade, agree=$agree)";
  }
}
