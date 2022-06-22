import 'dart:developer';

class SubjectData {
  String name; // 과목명
  double credit; // 학점 (이수 단위)
  String grade; // 학점 (성적)
  String professor; // 교수명

  SubjectData(this.name, this.credit, this.grade, this.professor);

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
      'B+': 3.3,
      'B0': 4.0,
      'B-': 4.5,
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

  @override
  String toString() {
    return subjectData.toString();
  }
}
