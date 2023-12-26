import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade/filesystem/FileSystem.dart';
import 'package:ssurade/types/YearSemester.dart';
import 'package:ssurade/types/subject/SemesterSubjects.dart';

part 'SemesterSubjectsManager.g.dart';

@JsonSerializable(converters: [_DataConverter()])
class SemesterSubjectsManager {
  static const int STATE_EMPTY = 0;
  static const int STATE_CATEGORY = 1 << 0; // 이수구분별 성적표에 의해 정보가 채워지면
  static const int STATE_SEMESTER = 1 << 1; // 학기별 성적 조회에 의해 정보가 채워지면
  static const int STATE_FULL = STATE_CATEGORY | STATE_SEMESTER;

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

  SemesterSubjectsManager merge(SemesterSubjectsManager other) {
    _state |= other._state;
    for (var subjects in other.data.values) {
      if (data.containsKey(subjects.currentSemester)) {
        data[subjects.currentSemester]!.merge(subjects);
      } else {
        data[subjects.currentSemester] = subjects;
      }
    }
    return this;
  }

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
    return SemesterSubjectsManager(SplayTreeMap(), STATE_EMPTY);
  }

  saveFile() => writeFile(_filename, jsonEncode(toJson()));
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
