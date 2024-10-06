import 'dart:convert';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/persistence/client/local_storage_client.dart';
import 'package:ssurade_application/ssurade_application.dart';

@Singleton(as: LocalStorageSettingPort)
class LocalStorageSettingService implements LocalStorageSettingPort {
  final LocalStorageClient _localStorage;

  const LocalStorageSettingService(this._localStorage);

  static String get _filename => 'setting.json';

  @override
  Future<Setting?> retrieveSetting() async {
    return (await _localStorage.readFile(_filename))?.let((it) {
      try {
        return Setting.fromJson(jsonDecode(it));
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<void> saveSetting(Setting setting) async {
    await _localStorage.writeFile(_filename, jsonEncode(setting.toJson()));
  }
}
