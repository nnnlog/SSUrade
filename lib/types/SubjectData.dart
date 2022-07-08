import 'dart:convert';

import 'package:ssurade/filesystem/FileSystem.dart';
import 'package:ssurade/types/Semester.dart';

const Map<String, double> gradeTable = {
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
  'F': -2,
};

class Ranking {
  int my, total;

  Ranking(this.my, this.total);

  double get percentage {
    return my / total * 100;
  }

  bool get isEmpty => my == 0 || total == 0;

  bool get isNotEmpty => !isEmpty;

  String toKey() => isEmpty ? "-" : "$my/$total";

  static Ranking fromKey(String str) {
    var a = str.split("/").map((e) => int.parse(e)).toList();
    return Ranking(a[0], a[1]);
  }

  @override
  String toString() => toKey();
}

class SubjectData {
  String name; // 과목명
  double credit; // 학점 (이수 단위)
  String grade; // 학점 (성적)
  String professor; // 교수명

  SubjectData(this.name, this.credit, this.grade, this.professor);

  static const String _name = 'name', _credit = 'credit', _grade = 'grade', _professor = 'professor';

  Map<String, dynamic> toJSON() => {
        _name: name,
        _credit: credit,
        _grade: grade,
        _professor: professor,
      };

  static SubjectData fromJSON(Map<String, dynamic> json) => SubjectData(json[_name], json[_credit], json[_grade], json[_professor]);

  @override
  String toString() {
    return "SubjectData(name=$name, credit=$credit, grade=$grade, professor=$professor)";
  }
}

class SubjectDataList {
  List<SubjectData> subjectDataList;
  Ranking semesterRanking, totalRanking;

  SubjectDataList(this.subjectDataList, this.semesterRanking, this.totalRanking);

  double get averageGrade {
    double totalGrade = 0, totalCredit = 0;

    for (var data in subjectDataList) {
      double? score = gradeTable[data.grade];
      if (score == null) continue;
      if (score < 0) continue;
      totalGrade += score * data.credit;
      totalCredit += data.credit;
    }
    if (totalCredit == 0) return 0;
    return totalGrade / totalCredit;
  }

  double get totalCredit {
    double ret = 0;
    for (var data in subjectDataList) {
      ret += data.credit;
    }

    return ret;
  }

  Map<String, dynamic> toJSON() =>
      {'subjects': subjectDataList.map((e) => e.toJSON()).toList(), 'semester_rank': semesterRanking.toKey(), 'total_rank': totalRanking.toKey()};

  static SubjectDataList fromJSON(Map<String, dynamic> json) => SubjectDataList(
      json['subjects'].map<SubjectData>((e) => SubjectData.fromJSON(e)).toList(),
      Ranking.fromKey(json['semester_rank']),
      Ranking.fromKey(json['total_rank']));

  @override
  String toString() =>
      "SubjectDataList(subjectDataList=${subjectDataList.toString()}, semesterRanking=${semesterRanking.toString()}, totalRanking=${totalRanking.toString()})";
}

class SubjectDataCache {
  Map<YearSemester, SubjectDataList> data;

  SubjectDataCache(this.data);

  bool get isEmpty => data.isEmpty;

  static const String _filename = "cache.json"; // internal file name

  static Future<SubjectDataCache> loadFromFile() async {
    try {
      if (await existFile(_filename)) {
        Map<String, dynamic> data = jsonDecode((await getFileContent(_filename))!);
        return fromJSON(data);
      }
    } catch (e, stacktrace) {}
    return SubjectDataCache({});
  }

  Map<String, Map<String, dynamic>> toJSON() => data.map((key, value) => MapEntry(key.toKey(), value.toJSON()));

  static SubjectDataCache fromJSON(Map<String, dynamic> json) =>
      SubjectDataCache(json.map((key, value) => MapEntry(YearSemester.fromKey(key), SubjectDataList.fromJSON(value))));

  saveFile() => writeFile(_filename, jsonEncode(toJSON()));

  @override
  String toString() => data.toString();
}
