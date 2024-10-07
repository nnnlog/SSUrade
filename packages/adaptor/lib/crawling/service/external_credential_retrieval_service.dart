import 'dart:concurrent';
import 'dart:convert';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/crawling/constant/crawling_timeout.dart';
import 'package:ssurade_adaptor/crawling/job/main_thread_crawling_job.dart';
import 'package:ssurade_adaptor/crawling/webview/web_view_client_service.dart';
import 'package:ssurade_application/domain/model/credential/credential.dart';
import 'package:ssurade_application/domain/model/job/job.dart';
import 'package:ssurade_application/port/out/external/external_credential_retrieval_port.dart';

@Singleton(as: ExternalCredentialRetrievalPort)
class ExternalCredentialRetrievalService implements ExternalCredentialRetrievalPort {
  final WebViewClientService _webViewClientService;
  final Map<(String, String), Mutex> _mutex = {};
  final Map<(String, String), int> _mutexCount = {};

  ExternalCredentialRetrievalService(this._webViewClientService);

  @override
  Job<List<Map<String, dynamic>>?> getCookiesFromCredential(Credential credential) {
    final key = (credential.id, credential.password);
    if (!_mutex.containsKey(key)) {
      _mutex[key] = Mutex();
      _mutexCount[key] = 0;
    }

    _mutexCount[key] = _mutexCount[key]! + 1;

    return MainThreadCrawlingJob(CrawlingTimeout.login, () {
      return _mutex[key]!.runLocked(() async {
        final client = await _webViewClientService.create();

        await run(() async {
          await client.loadPage("https://smartid.ssu.ac.kr/Symtra_sso/smln.asp?apiReturnUrl=https%3A%2F%2Fsaint.ssu.ac.kr%2FwebSSO%2Fsso.jsp");

          await client.execute('document.LoginInfo.userid.value = atob("${base64Encode(utf8.encode(credential.id))}");');
          await client.execute('document.LoginInfo.pwd.value = atob("${base64Encode(utf8.encode(credential.password))}");');
          await client.execute('document.LoginInfo.submit();');

          while (!(await client.url).startsWith("https://saint.ssu.ac.kr/irj/portal")) {
            await Future.delayed(const Duration(milliseconds: 1));
          }
        });

        await run(() async {
          await client.loadPage("https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW1001n?sap-language=KO");
          await client.execute("return await ssurade.lightspeed.waitForPageLoad();");
        });

        final result = await client.cookies.then((cookies) => cookies.map((cookie) => cookie.toJson()).toList());

        run(() {
          client.dispose();

          _mutexCount[key] = _mutexCount[key]! - 1;
          if (_mutexCount[key] == 0) {
            _mutex.remove(key);
            _mutexCount.remove(key);
          }
        });

        return result;
      });
    });
  }
}
