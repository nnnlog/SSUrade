import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade/filesystem/FileSystem.dart';
import 'package:ssurade/types/YearSemester.dart';
import 'package:ssurade/types/subject/SemesterSubjects.dart';

part 'SemesterSubjectsManager.g.dart';

@JsonSerializable()
class SemesterSubjectsManager {
  @_DataConverter()
  SplayTreeMap<YearSemester, SemesterSubjects> data;

  SemesterSubjectsManager(this.data);

  factory SemesterSubjectsManager.fromJson(Map<String, dynamic> json) => _$SemesterSubjectsManagerFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterSubjectsManagerToJson(this);

  bool get isEmpty => data.isEmpty;

  Future<void> initAllPassFailSubject() async {
    await Future.wait(data.values.map((data) => data.loadPassFailSubjects()));
  }

  @override
  String toString() => data.toString();

  // FILE I/O
  static const String _filename = "cache.json"; // internal file name

  static Future<SemesterSubjectsManager> loadFromFile() async {
    try {
      if (await existFile(_filename)) {
        Map<String, dynamic> data = jsonDecode((await readFile(_filename))!);
        return SemesterSubjectsManager.fromJson(data);
      }
    } catch (e, stacktrace) {
      log(e.toString());
      log(stacktrace.toString());
    }
    return SemesterSubjectsManager(SplayTreeMap.from({}));
  }

  saveFile() => writeFile(_filename, jsonEncode(toJson()));
}

class _DataConverter extends JsonConverter<SplayTreeMap<YearSemester, SemesterSubjects>, List<dynamic>> {
  const _DataConverter();

  @override
  SplayTreeMap<YearSemester, SemesterSubjects> fromJson(List<dynamic> json) {
    return SplayTreeMap.fromIterables(json.map((kv) => YearSemester.fromJson(kv[0])), json.map((kv) => SemesterSubjects.fromJson(kv[1])));
  }

  @override
  List<List<dynamic>> toJson(SplayTreeMap<YearSemester, SemesterSubjects> object) {
    return object.entries.map((entry) => [entry.key, entry.value]).toList();
  }
}
