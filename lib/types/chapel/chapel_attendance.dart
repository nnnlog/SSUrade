import 'package:flutter/material.dart';

enum ChapelAttendance {
  unknown("미결"),
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

  Color get color {
    if (this == ChapelAttendance.attend) return Colors.green;
    if (this == ChapelAttendance.absent) return Colors.redAccent;
    return Colors.black54;
  }
}
