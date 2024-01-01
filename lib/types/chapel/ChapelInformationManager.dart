import 'dart:collection';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:ssurade/filesystem/FileSystem.dart';
import 'package:ssurade/types/chapel/ChapelInformation.dart';

part 'ChapelInformationManager.g.dart';

@JsonSerializable(converters: [_DataConverter()])
class ChapelInformationManager {
  @JsonKey()
  SplayTreeSet<ChapelInformation> data;

  ChapelInformationManager(this.data);

  factory ChapelInformationManager.fromJson(Map<String, dynamic> json) => _$ChapelInformationManagerFromJson(json);

  Map<String, dynamic> toJson() => _$ChapelInformationManagerToJson(this);

  @override
  String toString() {
    return "$runtimeType(data=$data)";
  }

  bool get isEmpty => data.isEmpty;

  bool get isNotEmpty => data.isNotEmpty;

  // FILE I/O
  static const String _filename = "chapel.json"; // internal file name

  static Future<ChapelInformationManager> loadFromFile() async {
    try {
      if (await existFile(_filename)) {
        Map<String, dynamic> data = jsonDecode((await readFile(_filename))!);
        return ChapelInformationManager.fromJson(data);
      }
    } catch (e, stacktrace) {
      Logger().e(e, stackTrace: stacktrace);
    }
    return ChapelInformationManager(SplayTreeSet());
  }

  saveFile() => writeFile(_filename, jsonEncode(toJson()));
}

class _DataConverter extends JsonConverter<SplayTreeSet<ChapelInformation>, List<dynamic>> {
  const _DataConverter();

  @override
  SplayTreeSet<ChapelInformation> fromJson(List<dynamic> json) {
    return SplayTreeSet.from(json.map((e) => ChapelInformation.fromJson(e)));
  }

  @override
  List<dynamic> toJson(SplayTreeSet<ChapelInformation> object) {
    return object.toList();
  }
}
