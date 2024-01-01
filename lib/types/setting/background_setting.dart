import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade/filesystem/filesystem.dart';

part 'background_setting.g.dart';

@JsonSerializable()
class BackgroundSetting {
  @JsonKey()
  int notificationId;

  BackgroundSetting(this.notificationId);

  factory BackgroundSetting.fromJson(Map<String, dynamic> json) => _$BackgroundSettingFromJson(json);

  Map<String, dynamic> toJson() => _$BackgroundSettingToJson(this);

  static const String _filename = "bg_settings.json"; // internal file name

  static Future<BackgroundSetting> loadFromFile() async {
    try {
      dynamic json = {};
      if (await existFile(_filename)) {
        json = jsonDecode((await readFile(_filename))!);
      }
      return BackgroundSetting.fromJson(json);
    } catch (e) {
      return BackgroundSetting(0);
    }
  }

  saveFile() => writeFile(_filename, jsonEncode(toJson()));

  @override
  String toString() {
    return "$runtimeType(notificationId=$notificationId)";
  }
}
