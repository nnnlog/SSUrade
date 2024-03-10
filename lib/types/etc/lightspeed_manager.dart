import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:ssurade/filesystem/filesystem.dart';

part 'lightspeed_manager.g.dart';

@JsonSerializable()
class LightspeedManager {
  @JsonKey()
  String version;
  @JsonKey()
  String data;

  LightspeedManager(this.version, this.data);

  factory LightspeedManager.fromJson(Map<String, dynamic> json) => _$LightspeedManagerFromJson(json);

  Map<String, dynamic> toJson() => _$LightspeedManagerToJson(this);

  @override
  String toString() {
    return "$runtimeType(data=$data)";
  }

  bool get isEmpty => data.isEmpty;

  bool get isNotEmpty => data.isNotEmpty;

  // FILE I/O
  static const String _filename = "lightspeed.json"; // internal file name

  static Future<LightspeedManager> loadFromFile() async {
    try {
      if (await existFile(_filename)) {
        Map<String, dynamic> data = jsonDecode((await readFile(_filename))!);
        return LightspeedManager.fromJson(data);
      }
    } catch (e, stacktrace) {
      Logger().e(e, stackTrace: stacktrace);
    }
    return LightspeedManager("", "");
  }

  Future<String>? _future = null;

  Future<String> get(String version) async {
    if (_future != null) return await _future!;

    if (version != this.version || isEmpty) {
      var completer = Completer<String>();
      _future = completer.future;

      var data = (await http.get(Uri.parse("https://ecc.ssu.ac.kr/sap/public/bc/ur/nw7/js/dbg/lightspeed.js"))).body;
      data = data.replaceAll("oObject && aMethods", "false");

      this.data = data;
      this.version = version;
      saveFile();

      _future = null;
      completer.complete(data);
    }

    return data;
  }

  saveFile() => writeFile(_filename, jsonEncode(toJson()));
}
