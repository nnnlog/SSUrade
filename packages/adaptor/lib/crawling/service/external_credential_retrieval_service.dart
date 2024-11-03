import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/crawling/constant/crawling_timeout.dart';
import 'package:ssurade_adaptor/crawling/job/main_thread_crawling_job.dart';
import 'package:ssurade_adaptor/crawling/service/common/credential_retrieval_service.dart';
import 'package:ssurade_adaptor/crawling/webview/web_view_client_service.dart';
import 'package:ssurade_application/domain/model/credential/credential.dart';
import 'package:ssurade_application/domain/model/job/job.dart';
import 'package:ssurade_application/port/out/external/external_credential_retrieval_port.dart';

@module
abstract class ExternalCredentialRetrievalServiceModule {
  @injectable
  ExternalCredentialRetrievalPort get externalCredentialRetrievalPort => GetIt.I.get<ExternalCredentialRetrievalService>();
}

@singleton
class ExternalCredentialRetrievalService implements ExternalCredentialRetrievalPort {
  final WebViewClientService _webViewClientService;
  final CredentialRetrievalService _credentialRetrievalService;

  ExternalCredentialRetrievalService(this._webViewClientService, this._credentialRetrievalService);

  @override
  Job<List<Map<String, dynamic>>?> getCookiesFromCredential(Credential credential) {
    return MainThreadCrawlingJob(CrawlingTimeout.login, () async {
      var client = await _webViewClientService.create();

      return run(() async {
        return await _credentialRetrievalService.getCookiesFromCredential(client, credential);
      }).whenComplete(() {
        client.dispose();
      });
    });
  }
}
