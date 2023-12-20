import 'dart:core';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart' as secureStorage;
import 'package:path_provider/path_provider.dart';

late Directory internalDir;

initFileSystem() async {
  internalDir = await getApplicationDocumentsDirectory();

  if (!await existFile("first") && !await existFile("settings.json")) { // settings.json: legacy..
    await writeFile("first", "");
    await const secureStorage.FlutterSecureStorage(aOptions: secureStorage.AndroidOptions(encryptedSharedPreferences: true)).deleteAll();
  }
}

String getPath(String name) => "${internalDir.path}/$name";

Future<Directory> mkdir(String dirname) async {
  return Directory(getPath("$dirname/")).create(recursive: true);
}

Future<FileSystemEntity> rmdir(String dirname) async {
  return Directory(getPath("$dirname/")).delete(recursive: true);
}

Future<bool> existFile(String path) async {
  return FileSystemEntity.isFile(getPath(path));
}

Future<String?> readFile(String path) async {
  if (await existFile(path)) return File(getPath(path)).readAsString();
  return null;
}

Future<void> writeFile(String filename, String content) => File(getPath(filename)).writeAsString(content);
