import 'dart:convert';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/persistence/client/local_storage_client.dart';
import 'package:ssurade_application/ssurade_application.dart';

@module
abstract class LocalStorageSemesterSubjectsManagerServiceModule {
  @injectable
  LocalStorageSemesterSubjectsManagerRetrievalPort get i1 => GetIt.I.get<LocalStorageSemesterSubjectsManagerService>();

  @injectable
  LocalStorageSemesterSubjectsManagerSavePort get i2 => GetIt.I.get<LocalStorageSemesterSubjectsManagerService>();
}

@singleton
class LocalStorageSemesterSubjectsManagerService implements LocalStorageSemesterSubjectsManagerRetrievalPort, LocalStorageSemesterSubjectsManagerSavePort {
  final LocalStorageClient _localStorage;

  const LocalStorageSemesterSubjectsManagerService(this._localStorage);

  static String get _filename => 'subjects.json';

  @override
  Future<SemesterSubjectsManager?> retrieveSemesterSubjectsManager() async {
    return (await _localStorage.readFile(_filename))?.let((it) {
      try {
        return SemesterSubjectsManager.fromJson(jsonDecode(it));
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<void> saveSemesterSubjectsManager(SemesterSubjectsManager semesterSubjectsManager) async {
    _localStorage.writeFile(_filename, jsonEncode(semesterSubjectsManager.toJson()));
  }
}
