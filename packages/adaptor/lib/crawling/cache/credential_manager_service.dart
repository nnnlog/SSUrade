import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:mutex/mutex.dart';
import 'package:ssurade_adaptor/crawling/cache/credential_cache.dart';
import 'package:ssurade_adaptor/crawling/service/common/credential_retrieval_service.dart';
import 'package:ssurade_adaptor/crawling/webview/web_view_client.dart';
import 'package:ssurade_adaptor/persistence/client/local_storage_client.dart';
import 'package:ssurade_adaptor/persistence/localstorage/local_storage_credential_service.dart';

@singleton
class CredentialManagerService {
  bool _initialized = false;
  CredentialCache _credentialCache;

  final LocalStorageClient _localStorageClient;
  final LocalStorageCredentialService _localStorageCredentialService;
  final CredentialRetrievalService _credentialRetrievalService;

  final Mutex _mutex = Mutex();

  CredentialManagerService({
    required LocalStorageClient localStorageClient,
    required LocalStorageCredentialService localStorageCredentialService,
    required CredentialRetrievalService credentialRetrievalService,
  })  : _credentialCache = const CredentialCache(cookies: [], expire: null),
        _localStorageClient = localStorageClient,
        _localStorageCredentialService = localStorageCredentialService,
        _credentialRetrievalService = credentialRetrievalService {
    _localStorageCredentialService.onCredentialChanged.listen((credential) {
      clearCookies();
    });
  }

  static const String _filename = 'cookies.json';

  Future<void> _writeFile() async {
    await this._localStorageClient.writeFile(_filename, jsonEncode(_credentialCache.toJson()));
  }

  bool get hasCookies => _credentialCache.cookies.isNotEmpty;

  Future<void> setCookies(List<Map<String, dynamic>> cookies) async {
    _initialized = true;
    _credentialCache = CredentialCache(
      cookies: cookies,
      expire: DateTime.now().add(Duration(hours: 1)),
    );

    _writeFile();
  }

  Future<void> clearCookies() async {
    _initialized = true;
    _credentialCache = CredentialCache(cookies: [], expire: DateTime.now());
    _writeFile();
  }

  Future<List<Map<String, dynamic>>> getCookies(WebViewClient client) async {
    return _mutex.protect(() async {
      if (!_initialized) {
        _initialized = true;

        final json = await _localStorageClient.readFile(_filename);
        if (json != null) {
          final data = jsonDecode(json);
          _credentialCache = CredentialCache(cookies: (data['cookies'] as List).cast<Map<String, dynamic>>(), expire: data['expires']);
        }
      }

      if (_credentialCache.cookies.isEmpty || [null, true].contains(_credentialCache.expire?.isBefore(DateTime.now()))) {
        final credential = await _localStorageCredentialService.retrieveCredential();
        if (credential == null) throw Exception('No credential found');

        final cookies = await _credentialRetrievalService.getCookiesFromCredential(client, credential);
        if (cookies == null) throw Exception('Failed to login');

        _credentialCache = CredentialCache(cookies: cookies, expire: DateTime.now().add(Duration(hours: 1)));
        _writeFile();

        return cookies;
      }

      return _credentialCache.cookies;
    });
  }
}
