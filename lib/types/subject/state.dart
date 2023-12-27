const int STATE_EMPTY = 0;
const int STATE_CATEGORY = 1 << 0; // 이수구분별 성적표에 의해 정보가 채워지면
const int STATE_SEMESTER = 1 << 1; // 학기별 성적 조회에 의해 정보가 채워지면
const int STATE_FULL = STATE_CATEGORY | STATE_SEMESTER;
