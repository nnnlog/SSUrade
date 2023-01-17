class Subject {
  String code; // 과목 번호
  String name; // 과목명
  double credit; // 학점 (이수 단위)
  String grade; // 학점 (성적)
  String professor; // 교수명

  Subject(this.code, this.name, this.credit, this.grade, this.professor);

  @override
  String toString() {
    return "$runtimeType(code=$code, name=$name, credit=$credit, grade=$grade, professor=$professor)";
  }

  // FILE I/O
  static const String _code = 'code', _name = 'name', _credit = 'credit', _grade = 'grade', _professor = 'professor';

  Map<String, dynamic> toJSON() => {
        _code: code,
        _name: name,
        _credit: credit,
        _grade: grade,
        _professor: professor,
      };

  static Subject fromJSON(Map<String, dynamic> json) => Subject(json[_code], json[_name], json[_credit], json[_grade], json[_professor]);
}
