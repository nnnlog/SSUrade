enum ChapelAttendanceStatus {
  unknown,
  absent,
  attend;

  String get displayName {
    switch (this) {
      case ChapelAttendanceStatus.unknown:
        return "미결";
      case ChapelAttendanceStatus.absent:
        return "결석";
      case ChapelAttendanceStatus.attend:
        return "출석";
    }
  }

  // Color get color {
  //   if (this == ChapelAttendance.attend) return Colors.green;
  //   if (this == ChapelAttendance.absent) return Colors.redAccent;
  //   return Colors.black54;
  // }
}
