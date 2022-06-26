import 'dart:convert';

import 'package:ssurade/filesystem/FileSystem.dart';
import 'package:ssurade/types/Semester.dart';

class SubjectData {
  String name; // 과목명
  double credit; // 학점 (이수 단위)
  String grade; // 학점 (성적)
  String professor; // 교수명

  SubjectData(this.name, this.credit, this.grade, this.professor);

  Map<String, dynamic> toJSON() => {
        'name': name,
        'credit': credit,
        'grade': grade,
        'professor': professor,
      };

  static SubjectData fromJSON(Map<String, dynamic> json) => SubjectData(json['name'], json['credit'], json['grade'], json['professor']);

  @override
  String toString() {
    return "SubjectData(name=$name, credit=$credit, grade=$grade, professor=$professor)";
  }
}

class SubjectDataList {
  List<SubjectData> subjectData;

  SubjectDataList(this.subjectData);

  double get averageGrade {
    double totalGrade = 0, totalCredit = 0;

    Map<String, double> gradeTable = {
      'A+': 4.5,
      'A0': 4.3,
      'A-': 4.0,
      'B+': 3.5,
      'B0': 3.3,
      'B-': 3.0,
      'C+': 2.5,
      'C0': 2.3,
      'C-': 2.0,
      'D+': 1.5,
      'D0': 1.3,
      'D-': 1.0,
      'P': -1,
      'F': -1,
    };

    for (var data in subjectData) {
      if (gradeTable[data.grade] == null) continue;
      double real = gradeTable[data.grade]!;
      if (real == -1) continue;
      totalGrade += real * data.credit;
      totalCredit += data.credit;
    }
    if (totalCredit == 0) return 0;
    return totalGrade / totalCredit;
  }

  double get totalCredit {
    double ret = 0;
    for (var data in subjectData) {
      ret += data.credit;
    }

    return ret;
  }

  List<Map<String, dynamic>> toJSON() => subjectData.map((e) => e.toJSON()).toList();

  static SubjectDataList fromJSON(List<dynamic> json) => SubjectDataList(json.map((e) => SubjectData.fromJSON(e)).toList());

  @override
  String toString() => subjectData.toString();
}

class SubjectDataCache {
  Map<YearSemester, SubjectDataList> data;

  SubjectDataCache(this.data);

  bool get isEmpty => data.isEmpty;

  static const String _filename = "cache.json"; // internal file name

  static Future<SubjectDataCache> loadFromFile() async {
    if (!await existFile(_filename)) {
      return SubjectDataCache({});
    }

    Map<String, dynamic> data = jsonDecode((await getFileContent(_filename))!);
    return fromJSON(data);
  }

  Map<String, List<Map<String, dynamic>>> toJSON() => data.map((key, value) => MapEntry(key.toKey(), value.toJSON()));

  static SubjectDataCache fromJSON(Map<String, dynamic> json) =>
      SubjectDataCache(json.map((key, value) => MapEntry(YearSemester.fromKey(key), SubjectDataList.fromJSON(value))));

  saveFile() => writeFile(_filename, jsonEncode(toJSON()));

  @override
  String toString() => data.toString();
}
