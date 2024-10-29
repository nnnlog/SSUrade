import 'dart:collection';

import 'package:injectable/injectable.dart';
import 'package:parallel_worker/parallel_worker.dart';
import 'package:ssurade_adaptor/crawling/constant/crawling_timeout.dart';
import 'package:ssurade_adaptor/crawling/job/main_thread_crawling_job.dart';
import 'package:ssurade_adaptor/crawling/webview/web_view_client.dart';
import 'package:ssurade_adaptor/crawling/webview/web_view_client_service.dart';
import 'package:ssurade_application/ssurade_application.dart';

@Singleton(as: ExternalChapelManagerRetrievalPort)
class ExternalChapelRetrievalService implements ExternalChapelManagerRetrievalPort {
  WebViewClientService _webViewClientService;

  ExternalChapelRetrievalService(this._webViewClientService);

  Future<Chapel?> _getChapel(WebViewClient client, YearSemester yearSemester) async {
    return client.execute("return await ssurade.crawl.getChapelInformation('${yearSemester.year}', '${yearSemester.semester.rawIntegerValue}').catch(() => {});").then((res) {
      var summary = res["summary"];
      if (summary == null || res["attendance"].length == 0) {
        return null;
      }

      return Chapel(
        currentSemester: yearSemester,
        subjectCode: summary["subject_code"],
        subjectPlace: summary["subject_place"],
        subjectTime: summary["subject_time"],
        floor: summary["floor"],
        seatNo: summary["seat_no"],
        attendances: SplayTreeMap.fromIterable(
          res["attendance"].map((e) {
            return ChapelAttendance(
              status: ChapelAttendanceStatus.from(e["attendance"]),
              overwrittenStatus: ChapelAttendanceStatus.unknown,
              affiliation: e["affiliation"],
              lectureDate: e["lecture_date"],
              lectureEtc: e["lecture_etc"],
              lectureName: e["lecture_name"],
              lectureType: e["lecture_type"],
              lecturer: e["lecturer"],
            );
          }).toList(),
          key: (attendance) => attendance.lectureDate,
        ),
      );
    });
  }

  static String get _url => "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW3681?sap-language=KO";

  static int get _webViewCount => 3;

  @override
  Job<List<Chapel>> retrieveChapels(List<YearSemester> yearSemesters) {
    return MainThreadCrawlingJob(CrawlingTimeout.chapel, () async {
      final clients = await Future.wait(List.filled(_webViewCount, null).map((_) {
        return _webViewClientService.create();
      }).toList());

      await Future.wait(clients.map((client) => client.loadPage(_url)));

      final chapels = await ParallelWorker(
        jobs: yearSemesters.map((yearSemester) {
          return (client) => _getChapel(client, yearSemester);
        }).toList(),
        workers: clients,
      ).result;

      clients.forEach((client) {
        client.dispose();
      });

      return chapels.whereType<Chapel>().toList();
    });
  }

  @override
  Job<Chapel?> retrieveChapel(YearSemester yearSemester) {
    return MainThreadCrawlingJob(CrawlingTimeout.chapel, () async {
      final client = await _webViewClientService.create();

      await client.loadPage(_url);

      return _getChapel(client, yearSemester).whenComplete(() {
        client.dispose();
      });
    });
  }
}
