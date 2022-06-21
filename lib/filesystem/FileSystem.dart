import 'dart:core';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

late Directory internalDir;

initFileSystem() async {
  internalDir = await getApplicationDocumentsDirectory();
}

String getPath(String filename) => "${internalDir.path}/$filename";

Future<bool> existFile(String filename) async {
  return FileSystemEntity.isFile(getPath(filename));
}

Future<String?> getFileContent(String filename) async {
  if (await existFile(filename)) return File(getPath(filename)).readAsString();
  return null;
}

Future<void> writeFile(String filename, String content) => File(getPath(filename)).writeAsString(content);
