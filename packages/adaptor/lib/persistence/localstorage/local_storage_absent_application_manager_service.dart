import 'dart:convert';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/persistence/client/local_storage_client.dart';
import 'package:ssurade_application/ssurade_application.dart';

@Singleton(as: LocalStorageAbsentApplicationManagerPort)
class LocalStorageAbsentApplicationManagerService implements LocalStorageAbsentApplicationManagerPort {
  final LocalStorageClient _localStorage;

  const LocalStorageAbsentApplicationManagerService(this._localStorage);

  static String get _filename => 'absent.json';

  @override
  Future<AbsentApplicationManager?> retrieveAbsentApplicationManager() async {
    return (await _localStorage.readFile(_filename))?.let((it) {
      try {
        return AbsentApplicationManager.fromJson(jsonDecode(it));
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<void> saveAbsentApplicationManager(AbsentApplicationManager absentApplicationManager) async {
    await _localStorage.writeFile(_filename, jsonEncode(absentApplicationManager.toJson()));
  }
}
