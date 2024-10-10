class SubjectState {
  SubjectState._();

  static const int empty = 0;
  static const int category = 1 << 0; // 이수구분별 성적표에 의해 정보가 채워지면
  static const int semester = 1 << 1; // 학기별 성적 조회에 의해 정보가 채워지면
  static const int full = category | semester;
}
