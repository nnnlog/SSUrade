import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@preResolve
@singleton
class LocalStorageClient {
  final String _internalDir;

  const LocalStorageClient._(this._internalDir);

  @factoryMethod
  static Future<LocalStorageClient> init() async {
    return LocalStorageClient._((await getApplicationDocumentsDirectory()).path);
  }

  String _getPath(String name) => "$_internalDir/$name";

  Future<bool> existFile(String path) async {
    return FileSystemEntity.isFile(_getPath(path));
  }

  Future<String?> readFile(String path) async {
    if (await existFile(path)) return File(_getPath(path)).readAsString();
    return null;
  }

  Future<void> writeFile(String filename, String content) => File(_getPath(filename)).writeAsString(content);
}
