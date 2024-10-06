import 'dart:convert';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/persistence/client/local_storage_client.dart';
import 'package:ssurade_application/ssurade_application.dart';

@Singleton(as: LocalStorageSemesterSubjectsManagerPort)
class LocalStorageSemesterSubjectsManagerService implements LocalStorageSemesterSubjectsManagerPort {
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
