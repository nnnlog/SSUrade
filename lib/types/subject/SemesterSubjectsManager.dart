import 'dart:collection';
import 'dart:convert';

import 'package:ssurade/filesystem/FileSystem.dart';
import 'package:ssurade/types/YearSemester.dart';
import 'package:ssurade/types/subject/SemesterSubjects.dart';

class SemesterSubjectsManager {
  SplayTreeMap<YearSemester, SemesterSubjects> data;

  SemesterSubjectsManager(this.data);

  bool get isEmpty => data.isEmpty;

  Future<void> initAllPassFailSubject() async {
    await Future.wait(data.values.map((data) => data.loadPassFailSubjects()));
  }

  @override
  String toString() => data.toString();

  // FILE I/O
  static const String _filename = "cache.json"; // internal file name

  Map<String, Map<String, dynamic>> toJSON() => data.map((key, value) => MapEntry(key.toKey(), value.toJSON()));

  static SemesterSubjectsManager fromJSON(Map<String, dynamic> json) =>
      SemesterSubjectsManager(SplayTreeMap.from(json.map((key, value) => MapEntry(YearSemester.fromKey(key), SemesterSubjects.fromJSON(value)))));

  static Future<SemesterSubjectsManager> loadFromFile() async {
    try {
      if (await existFile(_filename)) {
        Map<String, dynamic> data = jsonDecode((await readFile(_filename))!);
        return fromJSON(data);
      }
    } catch (e, stacktrace) {}
    return SemesterSubjectsManager(SplayTreeMap.from({}));
  }

  saveFile() => writeFile(_filename, jsonEncode(toJSON()));
}
