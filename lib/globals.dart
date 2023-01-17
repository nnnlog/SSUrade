library ssurade.globals;

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ssurade/filesystem/FileSystem.dart';
import 'package:ssurade/types/Progress.dart';
import 'package:ssurade/types/Setting.dart';
import 'package:ssurade/types/subject/SemesterSubjectsManager.dart';

bool webViewInitialized = false;
int webViewXHRRunningCount = 0, webViewXHRTotalCount = 0;
XHRProgress webViewXHRProgress = XHRProgress.none;
String currentXHR = "";
Map<String, int> detectedXHR = {};
late InAppWebViewController webViewController;
Function jsAlertCallback = () {};

late Setting setting;
late SemesterSubjectsManager semesterSubjectsManager;
late Function setStateOfMainPage;

bool isLightMode = true; // SchedulerBinding.instance.window.platformBrightness == Brightness.light;

Future<void> init() async {
  await initFileSystem();
  setting = await Setting.loadFromFile();
  semesterSubjectsManager = await SemesterSubjectsManager.loadFromFile();
  await semesterSubjectsManager.initAllPassFailSubject();
}
