import 'dart:convert';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/persistence/client/local_storage_client.dart';
import 'package:ssurade_application/ssurade_application.dart';

@Singleton(as: LocalStorageScholarshipManagerPort)
class LocalStorageScholarshipManagerService implements LocalStorageScholarshipManagerPort {
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
