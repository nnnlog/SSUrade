library ssurade.globals;

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ssurade/filesystem/FileSystem.dart';
import 'package:ssurade/types/Progress.dart';
import 'package:ssurade/types/Setting.dart';

bool webViewInitialized = false;
int webViewXHRRunningCount = 0, webViewXHRTotalCount = 0;
XHRProgress webViewXHRProgress = XHRProgress.none;
late InAppWebViewController webViewController;
Function jsAlertCallback = () {};

late Setting setting;
late Function setStateOfMainPage;

Future<void> init() async {
  await initFileSystem();
  setting = await Setting.loadFromFile();
}
