import 'dart:convert';

import 'package:ssurade/crawling/USaintSession.dart';
import 'package:ssurade/filesystem/FileSystem.dart';

class Setting {
  late USaintSession saintSession;

  Setting(String number, String password) {
    saintSession = USaintSession(number, password);
  }

  static const String _filename = "settings.json"; // internal file name
  static const String __number = "number", _password = "password"; // field schema

  static Future<Setting> loadFromFile() async {
    if (!await existFile(_filename)) {
      return Setting("", "");
    }

    var data = jsonDecode((await getFileContent(_filename))!);
    return Setting(data[__number] ?? "", data[_password] ?? "");
  }

  saveFile() => writeFile(
        _filename,
        jsonEncode({
          __number: saintSession.number,
          _password: saintSession.password,
        }));

  @override
  String toString() {
    return "Setting(saint_session=$saintSession)";
  }
}
