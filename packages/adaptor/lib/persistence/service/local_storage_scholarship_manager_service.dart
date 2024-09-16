import 'dart:convert';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/persistence/client/local_storage_client.dart';
import 'package:ssurade_application/ssurade_application.dart';

@module
abstract class LocalStorageScholarshipManagerServiceModule {
  @injectable
  LocalStorageScholarshipManagerRetrievalPort get i1 => GetIt.I.get<LocalStorageScholarshipManagerService>();

  @injectable
  LocalStorageScholarshipManagerSavePort get i2 => GetIt.I.get<LocalStorageScholarshipManagerService>();
}

@singleton
class LocalStorageScholarshipManagerService implements LocalStorageScholarshipManagerRetrievalPort, LocalStorageScholarshipManagerSavePort {
  final LocalStorageClient _localStorage;

  const LocalStorageScholarshipManagerService(this._localStorage);

  static String get _filename => 'scholarship.json';

  @override
  Future<ScholarshipManager?> retrieveScholarshipManager() async {
    return (await _localStorage.readFile(_filename))?.let((it) {
      try {
        return ScholarshipManager.fromJson(jsonDecode(it));
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<void> saveScholarshipManager(ScholarshipManager scholarshipManager) async {
    _localStorage.writeFile(_filename, jsonEncode(scholarshipManager.toJson()));
  }
}
