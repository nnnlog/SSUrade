import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/src/in_app_webview/in_app_webview_controller.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/crawler.dart';
import 'package:ssurade/crawling/common/crawling_task.dart';
import 'package:ssurade/crawling/common/webview_controller_extension.dart';
import 'package:ssurade/crawling/error/no_data_exception.dart';
import 'package:ssurade/types/chapel/chapel_information.dart';
import 'package:ssurade/types/chapel/chapel_information_manager.dart';
import 'package:ssurade/types/semester/semester.dart';
import 'package:ssurade/types/semester/year_semester.dart';

class AllChapel extends CrawlingTask<ChapelInformationManager> {
  List<YearSemester> search;

  factory AllChapel.get(
    List<YearSemester> search, {
    ISentrySpan? parentTransaction,
  }) =>
      AllChapel._(search, parentTransaction);

  AllChapel._(this.search, super.parentTransaction);

  static const chapelCountPerController = 3;

  @override
  String getTaskId() {
    return "all_chapel";
  }

  @override
  int getTimeout() {
    return getWebViewCount() * 10 + chapelCountPerController * 10;
  }

  @override
  int getWebViewCount() {
    int cnt = search.length;
    return cnt ~/ chapelCountPerController + (cnt % chapelCountPerController > 0 ? 1 : 0);
  }

  @override
  Future<ChapelInformationManager> internalExecute(Queue<InAppWebViewController> controllers, [Completer? onComplete]) async {
    assert(controllers.length == getWebViewCount());

    final transaction = parentTransaction?.startChild(getTaskId()) ?? Sentry.startTransaction('AllChapel', getTaskId());
    late ISentrySpan span;

    var subjects = Queue()..addAll(search);
    var dump = ChapelInformation(const YearSemester(0, Semester.first), SplayTreeSet());

    span = transaction.startChild("login_execute_js");
    ChapelInformationManager ret = ChapelInformationManager(SplayTreeSet());
    List<Future> futures = [];
    while (controllers.isNotEmpty) {
      var completer = Completer();
      futures.add(completer.future);

      var controller = controllers.removeFirst();
      var inputs = [];
      for (int j = 0; j < chapelCountPerController && subjects.isNotEmpty; j++) {
        inputs.add(subjects.removeFirst());
      }

      (() async {
        await controller.customLoadPage(
          "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW3681?sap-language=KO",
          parentTransaction: transaction,
          login: true,
        );

        for (var current in inputs) {
          ret.data.add(await Crawler.singleChapelBySemester(current, reloadPage: false, parentTransaction: transaction).directExecute(Queue()..add(controller)).catchError((e) {
            if (e is NoDataException) {
              return dump;
            }
          }));
        }

        completer.complete();
      })();
    }

    await Future.wait(futures);

    span.finish(status: const SpanStatus.ok());
    transaction.finish(status: const SpanStatus.ok());

    ret.data.remove(dump);
    return ret;
  }
}
