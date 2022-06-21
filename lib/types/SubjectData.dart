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
