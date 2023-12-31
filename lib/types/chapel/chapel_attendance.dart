enum ChapelAttendance {
  unknown(""),
  absent("결석"),
  attend("출석");

  final String display;

  const ChapelAttendance(this.display);

  factory ChapelAttendance.from(String str) {
    for (var value in ChapelAttendance.values) {
      if (str == value.display) return value;
    }
    return ChapelAttendance.unknown;
  }
}
