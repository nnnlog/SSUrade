import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/crawling/job/main_thread_crawling_job.dart';
import 'package:ssurade_adaptor/crawling/webview/web_view_client_service.dart';
import 'package:ssurade_application/ssurade_application.dart';

@Singleton(as: ExternalScholarshipManagerRetrievalPort)
class ExternalScholarshipManagerRetrievalService implements ExternalScholarshipManagerRetrievalPort {
  WebViewClientService _webViewClientService;

  ExternalScholarshipManagerRetrievalService(this._webViewClientService);

  @override
  Job<ScholarshipManager?> retrieveScholarshipManager() {
    return MainThreadCrawlingJob(() async {
      final client = await _webViewClientService.create();

      await client.loadPage("https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW7530n?sap-language=KO");

      return await client.execute("return await ssurade.crawl.getScholarshipInformation().catch(() => {});").then((value) {
        if (!(value is List)) {
          return null;
        }

        return ScholarshipManager(value
            .map((obj) => Scholarship(
                  when: YearSemester(
                    year: int.parse(obj["year"]),
                    semester: Semester.parse(obj["semester"]),
                  ),
                  name: obj["name"],
                  process: obj["process"],
                  price: obj["price"],
                ))
            .toList());
      }).whenComplete(() => client.dispose());
    });
  }
}
