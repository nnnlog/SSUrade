import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:ssurade/filesystem/filesystem.dart';
import 'package:ssurade/types/absent/absent_application_information.dart';

part 'absent_application_manager.g.dart';

// @JsonSerializable(converters: [_DataConverter()])
@JsonSerializable()
class AbsentApplicationManager {
  @JsonKey()
  List<AbsentApplicationInformation> data;

  // SplayTreeMap<YearSemester, List<AbsentApplicationInformation>> data;

  AbsentApplicationManager(this.data);

  factory AbsentApplicationManager.fromJson(Map<String, dynamic> json) => _$AbsentApplicationManagerFromJson(json);

  Map<String, dynamic> toJson() => _$AbsentApplicationManagerToJson(this);

  @override
  String toString() {
    return "$runtimeType(data=$data)";
  }

  bool get isEmpty => data.isEmpty;

  bool get isNotEmpty => data.isNotEmpty;

  // FILE I/O
  static const String _filename = "absent.json"; // internal file name

  static Future<AbsentApplicationManager> loadFromFile() async {
    try {
      if (await existFile(_filename)) {
        Map<String, dynamic> data = jsonDecode((await readFile(_filename))!);
        return AbsentApplicationManager.fromJson(data);
      }
    } catch (e, stacktrace) {
      Logger().e(e, stackTrace: stacktrace);
    }
    return AbsentApplicationManager([]);
    // return AbsentApplicationManager(SplayTreeMap());
  }

  saveFile() => writeFile(_filename, jsonEncode(toJson()));
}

// class _DataConverter extends JsonConverter<SplayTreeMap<YearSemester, List<AbsentApplicationInformation>>, Map<YearSemester, List<AbsentApplicationInformation>>> {
//   const _DataConverter();
//
//   @override
//   SplayTreeMap<YearSemester, List<AbsentApplicationInformation>> fromJson(Map json) {
//     return SplayTreeMap.from(json);
//   }
//
//   @override
//   Map<YearSemester, List<AbsentApplicationInformation>> toJson(SplayTreeMap<YearSemester, List<AbsentApplicationInformation>> object) {
//     return object;
//   }
// }
