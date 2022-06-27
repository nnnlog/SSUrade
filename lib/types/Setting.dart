import 'dart:convert';

import 'package:ssurade/crawling/USaintSession.dart';
import 'package:ssurade/filesystem/FileSystem.dart';

class Setting {
  late USaintSession uSaintSession;
  bool refreshGradeAutomatically;
  int timeoutGrade, timeoutAllGrade;

  Setting(String number, String password, this.refreshGradeAutomatically, this.timeoutGrade, this.timeoutAllGrade) {
    uSaintSession = USaintSession(number, password);
  }

  static const String _filename = "settings.json"; // internal file name

  // field schema
  static const String _number = "number", _password = "password";
  static const String _refreshGradeAutomatically = "refreshGradeAutomatically";
  static const String _timeoutGrade = "timeout_grade", _timeoutAllGrade = "timeout_all_grade";

  static Future<Setting> loadFromFile() async {
    dynamic data = {};
    if (await existFile(_filename)) {
      data = jsonDecode((await getFileContent(_filename))!);
    }

    return Setting(data[_number] ?? "", data[_password] ?? "", data[_refreshGradeAutomatically] ?? false, data[_timeoutGrade] ?? 10,
        data[_timeoutAllGrade] ?? 30);
  }

  saveFile() => writeFile(
      _filename,
      jsonEncode({
        _number: uSaintSession.number,
        _password: uSaintSession.password,
        _refreshGradeAutomatically: refreshGradeAutomatically,
        _timeoutGrade: timeoutGrade,
        _timeoutAllGrade: timeoutAllGrade,
      }));

  @override
  String toString() {
    return "Setting(saint_session=$uSaintSession, refreshGradeAutomatically=$refreshGradeAutomatically)";
  }
}
