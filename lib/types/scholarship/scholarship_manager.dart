import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:ssurade/filesystem/filesystem.dart';
import 'package:ssurade/types/scholarship/scholarship.dart';

part 'scholarship_manager.g.dart';

@JsonSerializable()
class ScholarshipManager {
  @JsonKey()
  List<Scholarship> data;

  ScholarshipManager(this.data);

  factory ScholarshipManager.fromJson(Map<String, dynamic> json) => _$ScholarshipManagerFromJson(json);

  Map<String, dynamic> toJson() => _$ScholarshipManagerToJson(this);

  @override
  String toString() {
    return "$runtimeType(data=$data)";
  }

  bool get isEmpty => data.isEmpty;

  bool get isNotEmpty => data.isNotEmpty;

  // FILE I/O
  static const String _filename = "scholarship.json"; // internal file name

  static Future<ScholarshipManager> loadFromFile() async {
    try {
      if (await existFile(_filename)) {
        Map<String, dynamic> data = jsonDecode((await readFile(_filename))!);
        return ScholarshipManager.fromJson(data);
      }
    } catch (e, stacktrace) {
      Logger().e(e, stackTrace: stacktrace);
    }
    return ScholarshipManager([]);
  }

  saveFile() => writeFile(_filename, jsonEncode(toJson()));
}
