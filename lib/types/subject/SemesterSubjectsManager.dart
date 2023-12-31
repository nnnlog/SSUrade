import 'dart:collection';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:ssurade/filesystem/FileSystem.dart';
import 'package:ssurade/types/semester/YearSemester.dart';
import 'package:ssurade/types/subject/SemesterSubjects.dart';
import 'package:ssurade/types/subject/state.dart';

part 'SemesterSubjectsManager.g.dart';

@JsonSerializable(converters: [_DataConverter()])
class SemesterSubjectsManager {
  @JsonKey(
    includeToJson: true,
    includeFromJson: true,
  )
  int _state = 0;

  @JsonKey()
  SplayTreeMap<YearSemester, SemesterSubjects> data;

  SemesterSubjectsManager(this.data, this._state);

  factory SemesterSubjectsManager.fromJson(Map<String, dynamic> json) => _$SemesterSubjectsManagerFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterSubjectsManagerToJson(this);

  int get state => _state;

  bool get isEmpty => data.isEmpty;

  bool get isNotEmpty => !isEmpty;

  List<SemesterSubjects> getIncompleteSemester() {
    List<SemesterSubjects> ret = [];
    for (var subjects in data.values) {
      if (subjects.getIncompleteSubjects().isNotEmpty || subjects.semesterRanking.isEmpty || subjects.totalRanking.isEmpty) {
        ret.add(subjects);
      }
    }
    return ret;
  }

  void cleanup() {
    for (var subjects in getIncompleteSemester()) {
      subjects.cleanup();
      if (subjects.isEmpty) {
        data.remove(subjects.currentSemester);
      }
    }
  }

  @override
  String toString() => data.toString();

  // FILE I/O
  static const String _filename = "grade.json"; // internal file name

  static Future<SemesterSubjectsManager> loadFromFile() async {
    try {
      if (await existFile(_filename)) {
        Map<String, dynamic> data = jsonDecode((await readFile(_filename))!);
        return SemesterSubjectsManager.fromJson(data);
      }
    } catch (e, stacktrace) {
      Logger().e(e, stackTrace: stacktrace);
    }
    return SemesterSubjectsManager(SplayTreeMap(), STATE_EMPTY);
  }

  saveFile() => writeFile(_filename, jsonEncode(toJson()));

  static SemesterSubjectsManager? merge(SemesterSubjectsManager after, SemesterSubjectsManager before) {
    if (after.state | before.state != STATE_FULL) return null;
    SemesterSubjectsManager ret = SemesterSubjectsManager(SplayTreeMap(), STATE_FULL);
    for (var key in after.data.keys) {
      if (before.data.containsKey(key)) {
        ret.data[key] = SemesterSubjects.merge(after.data[key]!, before.data[key]!, after.state, before.state)!;
      }
    }
    return ret;
  }
}

class _DataConverter extends JsonConverter<SplayTreeMap<YearSemester, SemesterSubjects>, List<dynamic>> {
  const _DataConverter();

  @override
  SplayTreeMap<YearSemester, SemesterSubjects> fromJson(List<dynamic> json) {
    var list = json.map((e) => SemesterSubjects.fromJson(e));
    return SplayTreeMap.fromIterables(list.map((e) => e.currentSemester), list);
  }

  @override
  List<dynamic> toJson(SplayTreeMap<YearSemester, SemesterSubjects> object) {
    return object.entries.map((entry) => entry.value).toList();
  }
}
