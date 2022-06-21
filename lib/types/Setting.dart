import 'dart:convert';

import 'package:ssurade/crawling/USaintSession.dart';
import 'package:ssurade/filesystem/FileSystem.dart';

class Setting {
  late USaintSession saintSession;

  Setting(String number, String password) {
    saintSession = USaintSession(number, password);
  }

  static const String _FILENAME = "settings.json"; // internal file name
  static const String _NUMBER = "number", _PASSWORD = "password"; // field schema

  static Future<Setting> loadFromFile() async {
    if (!await existFile(_FILENAME)) {
      return Setting("", "");
    }

    var data = jsonDecode((await getFileContent(_FILENAME))!);
    return Setting(data[_NUMBER] ?? "", data[_PASSWORD] ?? "");
  }

  saveFile() {
    writeFile(
        _FILENAME,
        jsonEncode({
          _NUMBER: saintSession.number,
          _PASSWORD: saintSession.password,
        }));
  }

  @override
  String toString() {
    return "Setting(saint_session=$saintSession)";
  }
}
