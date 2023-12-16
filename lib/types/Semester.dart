import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum Semester {
  first,
  summer,
  second,
  winter;

  static Semester parse(String str) {
    str = str.replaceAll(" ", "");
    for (var semester in Semester.values) {
      if (str == semester.name) {
        return semester;
      }
    }

    throw Exception("Unknown semester, got $str");
  }
}

extension SemesterExtension on Semester {
  String get name {
    switch (this) {
      case Semester.first:
        return "1학기";
      case Semester.summer:
        return "여름학기";
      case Semester.second:
        return "2학기";
      case Semester.winter:
        return "겨울학기";
    }
  }

  String get keyValue {
    switch (this) {
      case Semester.first:
        return "090";
      case Semester.summer:
        return "091";
      case Semester.second:
        return "092";
      case Semester.winter:
        return "093";
    }
  }

  String get textValue {
    switch (this) {
      case Semester.first:
        return "1 학기";
      case Semester.summer:
        return "여름학기";
      case Semester.second:
        return "2 학기";
      case Semester.winter:
        return "겨울학기";
    }
  }
}
