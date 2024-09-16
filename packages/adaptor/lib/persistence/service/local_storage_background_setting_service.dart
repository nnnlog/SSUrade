import 'dart:convert';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/persistence/client/local_storage_client.dart';
import 'package:ssurade_application/ssurade_application.dart';

@module
abstract class LocalStorageBackgroundSettingServiceModule {
  @injectable
  LocalStorageBackgroundSettingRetrievalPort get i1 => GetIt.I.get<LocalStorageBackgroundSettingService>();

  @injectable
  LocalStorageBackgroundSettingSavePort get i2 => GetIt.I.get<LocalStorageBackgroundSettingService>();
}

@singleton
class LocalStorageBackgroundSettingService implements LocalStorageBackgroundSettingRetrievalPort, LocalStorageBackgroundSettingSavePort {
  final LocalStorageClient _localStorage;

  const LocalStorageBackgroundSettingService(this._localStorage);

  static String get _filename => 'background_setting.json';

  @override
  Future<BackgroundSetting?> retrieveBackgroundSetting() async {
    return (await _localStorage.readFile(_filename))?.let((it) {
      try {
        return BackgroundSetting.fromJson(jsonDecode(it));
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<void> saveBackgroundSetting(BackgroundSetting backgroundSetting) async {
    await _localStorage.writeFile(_filename, jsonEncode(backgroundSetting.toJson()));
  }
}
