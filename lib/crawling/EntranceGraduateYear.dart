import 'dart:developer';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/Crawler.dart';
import 'package:ssurade/crawling/CrawlingTask.dart';
import 'package:ssurade/crawling/WebViewControllerExtension.dart';
import 'package:tuple/tuple.dart';

class EntranceGraduateYear extends CrawlingTask<Tuple2<String, String>?> {
  static final EntranceGraduateYear _instance = EntranceGraduateYear._();

  factory EntranceGraduateYear.get() {
    return _instance;
  }

  EntranceGraduateYear._();

  @override
  String task_id = "entrance_graduate_year";

  @override
  Future<Tuple2<String, String>?> internalExecute(InAppWebViewController controller) async {
    bool isFinished = false;

    late Tuple2<String, String>? result;
    try {
      result = await Future.any([
        Future(() async {
          if (isFinished) return null;
          if (!(await Crawler.loginSession().directExecute(controller))) {
            return null;
          }

          await controller.initForXHR();

          await controller.loadUrl(urlRequest: URLRequest(url: Uri.parse("https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW1001n?sap-language=KO")));

          await controller.waitForXHR();

          await Future.any([
            Future.doWhile(() async {
              if (isFinished) return false;
              try {
                String? entrance = await controller.evaluateJavascript(
                    source:
                        'document.querySelectorAll("table tr div div:nth-child(1) span span:nth-child(2) tbody:nth-child(2) tr td span span table tbody tr:nth-child(1) td:nth-child(1) table tr table tr:nth-child(1) td:nth-child(2) span input")[0].value;');
                if (entrance == null) return true;
                entrance = entrance.trim();
                if (entrance.isEmpty) return true;

                String? graduate = await controller.evaluateJavascript(
                    source:
                        'document.querySelectorAll("table tbody tr div div:nth-child(1) span span:nth-child(2) table tbody:nth-child(2) tr span span table tr:nth-child(1) td:nth-child(1) table tr table tr:nth-child(18) td:nth-child(2) span input")[0].value;');
                if (graduate == null) return true;
                graduate = graduate.trim();
                if (graduate.isEmpty) return true;

                result = Tuple2(entrance, graduate);
                return false;
              } catch (e, stacktrace) {
                log(e.toString());
                log(stacktrace.toString());
                await Future.delayed(const Duration(milliseconds: 100));
                return true;
              }
            }),
            Future.delayed(const Duration(seconds: 5))
          ]);

          return result;
        }),
        Future.delayed(const Duration(seconds: 10), () => null),
      ]);
    } catch (e, stacktrace) {
      log(e.toString());
      log(stacktrace.toString());

      Sentry.captureException(
        e,
        stackTrace: stacktrace,
      );

      return null;
    } finally {
      isFinished = true;
    }

    return result;
  }
}
