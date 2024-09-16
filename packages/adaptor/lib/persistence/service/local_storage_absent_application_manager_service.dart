import 'dart:convert';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/persistence/client/local_storage_client.dart';
import 'package:ssurade_application/ssurade_application.dart';

@module
abstract class LocalStorageAbsentApplicationManagerServiceModule {
  @injectable
  LocalStorageAbsentApplicationManagerRetrievalPort get i1 => GetIt.I.get<LocalStorageAbsentApplicationManagerService>();

  @injectable
  LocalStorageAbsentApplicationManagerSavePort get i2 => GetIt.I.get<LocalStorageAbsentApplicationManagerService>();
}

@singleton
class LocalStorageAbsentApplicationManagerService implements LocalStorageAbsentApplicationManagerRetrievalPort, LocalStorageAbsentApplicationManagerSavePort {
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
