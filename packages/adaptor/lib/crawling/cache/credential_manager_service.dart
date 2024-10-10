import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:mutex/mutex.dart';
import 'package:ssurade_adaptor/crawling/cache/credential_cache.dart';
import 'package:ssurade_adaptor/crawling/service/external_credential_retrieval_service.dart';
import 'package:ssurade_adaptor/persistence/client/local_storage_client.dart';
import 'package:ssurade_adaptor/persistence/localstorage/local_storage_credential_service.dart';

@singleton
class CredentialManagerService {
  bool _initialized = false;
  CredentialCache _credentialCache;

  final LocalStorageClient _localStorageClient;
  final LocalStorageCredentialService _localStorageCredentialService;
  final ExternalCredentialRetrievalService _externalCredentialRetrievalService;

  final ReadWriteMutex _mutex = ReadWriteMutex();

  CredentialManagerService({
    required CredentialCache credentialCache,
    required LocalStorageClient localStorageClient,
    required LocalStorageCredentialService localStorageCredentialService,
    required ExternalCredentialRetrievalService externalCredentialRetrievalService,
  })  : _credentialCache = credentialCache,
        _localStorageClient = localStorageClient,
        _localStorageCredentialService = localStorageCredentialService,
        _externalCredentialRetrievalService = externalCredentialRetrievalService;

  static const String _filename = 'cookies.json';

  Future<void> _writeFile() async {
    await this._localStorageClient.writeFile(_filename, jsonEncode(_credentialCache.toJson()));
  }

  bool get hasCookies => _credentialCache.cookies.isNotEmpty;

  Future<void> setCookies(List<Map<String, dynamic>> cookies) async {
    await _mutex.protectWrite(() async {
      _credentialCache = CredentialCache(
        cookies: cookies,
        expire: DateTime.now().add(Duration(hours: 1)),
      );

      _writeFile();
    });
  }

  Future<void> clearCookies() async {
    await _mutex.protectWrite(() async {
      _credentialCache = CredentialCache(cookies: [], expire: DateTime.now());
      _writeFile();
    });
  }

  Future<List<Map<String, dynamic>>> getCookies() async {
    if (!_initialized) {
      return _mutex.protectWrite(() async {
        _initialized = true;

        final json = await _localStorageClient.readFile(_filename);
        final data = json == null ? [] : jsonDecode(json);

        _credentialCache = CredentialCache(cookies: data['cookies'], expire: data['expires']);

        return _credentialCache.cookies;
      });
    }

    if (_credentialCache.cookies.isNotEmpty && _credentialCache.expire.isBefore(DateTime.now())) {
      return _mutex.protectWrite(() async {
        final credential = await _localStorageCredentialService.retrieveCredential();
        if (credential == null) throw Exception('No credential found');

        final cookies = await _externalCredentialRetrievalService.getCookiesFromCredential(credential).result;
        if (cookies == null) throw Exception('Failed to login');

        _credentialCache = CredentialCache(cookies: cookies, expire: DateTime.now().add(Duration(hours: 1)));
        _writeFile();

        return cookies;
      });
    }

    return _mutex.protectRead(() async {
      return _credentialCache.cookies;
    });
  }
}
