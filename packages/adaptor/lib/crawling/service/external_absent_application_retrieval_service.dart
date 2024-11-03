import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/crawling/constant/crawling_timeout.dart';
import 'package:ssurade_adaptor/crawling/job/main_thread_crawling_job.dart';
import 'package:ssurade_adaptor/crawling/webview/web_view_client_service.dart';
import 'package:ssurade_application/ssurade_application.dart';

@Singleton(as: ExternalAbsentApplicationRetrievalPort)
class ExternalAbsentApplicationRetrievalService implements ExternalAbsentApplicationRetrievalPort {
  WebViewClientService _webViewClientService;

  ExternalAbsentApplicationRetrievalService(this._webViewClientService);

  @override
  Job<AbsentApplicationManager?> retrieveAbsentManager() {
    return MainThreadCrawlingJob(CrawlingTimeout.absent, () async {
      final client = await _webViewClientService.create();

      return run(() async {
        await client.loadPage("https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW3683?sap-language=KO");

        return await client.execute("return await ssurade.crawl.getAbsentApplicationInformation().catch(() => {});").then((res) {
          if (!(res is List)) {
            return null;
          }

          final result = res
              .map((obj) => AbsentApplication(
            absentType: obj['absent_type'],
            startDate: obj['start_date'],
            endDate: obj['end_date'],
            absentCause: obj['absent_cause'],
            applicationDate: obj['application_date'],
            proceedDate: obj['proceed_date'],
            rejectCause: obj['reject_cause'],
            status: obj['status'],
          ))
              .toList();

          return AbsentApplicationManager(result);
        });
      }).whenComplete(() {
        client.dispose();
      });
    });
  }
}
