enum ChapelAttendanceStatus {
  unknown,
  absent,
  attend;

  String get displayText {
    switch (this) {
      case ChapelAttendanceStatus.unknown:
        return "미결";
      case ChapelAttendanceStatus.absent:
        return "결석";
      case ChapelAttendanceStatus.attend:
        return "출석";
    }
  }

  factory ChapelAttendanceStatus.from(String value) {
    switch (value) {
      case "결석":
        return ChapelAttendanceStatus.absent;
      case "출석":
        return ChapelAttendanceStatus.attend;
      default:
        return ChapelAttendanceStatus.unknown;
    }
  }
}
