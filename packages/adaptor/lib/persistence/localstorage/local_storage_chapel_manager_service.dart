import 'dart:convert';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/persistence/client/local_storage_client.dart';
import 'package:ssurade_application/ssurade_application.dart';

@Singleton(as: LocalStorageChapelManagerPort)
class LocalStorageChapelManagerService implements LocalStorageChapelManagerPort {
  final LocalStorageClient _localStorage;

  const LocalStorageChapelManagerService(this._localStorage);

  static String get _filename => 'chapel.json';

  @override
  Future<ChapelManager?> retrieveChapelManager() async {
    return (await _localStorage.readFile(_filename))?.let((it) {
      try {
        return ChapelManager.fromJson(jsonDecode(it));
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<void> saveChapelManager(ChapelManager chapelManager) async {
    await _localStorage.writeFile(_filename, jsonEncode(chapelManager.toJson()));
  }
}
