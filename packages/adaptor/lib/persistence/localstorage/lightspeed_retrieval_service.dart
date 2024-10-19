import 'dart:convert';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:mutex/mutex.dart';
import 'package:ssurade_adaptor/persistence/client/local_storage_client.dart';
import 'package:ssurade_application/ssurade_application.dart';

@singleton
class LightspeedRetrievalService {
  final LocalStorageClient _localStorage;
  final Mutex _mutex = Mutex();

  LightspeedRetrievalService(this._localStorage);

  static String get _filename => 'lightspeed.json';

  Future<Lightspeed?> _readLightspeed() async {
    return (await _localStorage.readFile(_filename))?.let((it) {
      try {
        return Lightspeed.fromJson(jsonDecode(it));
      } catch (e) {
        return null;
      }
    });
  }

  Future<void> _saveLightspeed(Lightspeed lightspeed) async {
    _localStorage.writeFile(_filename, jsonEncode(lightspeed.toJson()));
  }

  Future<Lightspeed> _downloadLightspeed(String version) async {
    return (await http.get(Uri.parse("https://ecc.ssu.ac.kr/sap/public/bc/ur/nw7/js/dbg/lightspeed.js"))).body.let((it) {
      return Lightspeed(version: version, data: it.replaceAll("oObject && aMethods", "false"));
    });
  }

  Future<Lightspeed> retrieveLightspeed(String version) {
    return _mutex.protect(() => _readLightspeed().then((lightspeed) async {
          if (lightspeed == null || lightspeed.version != version) {
            return await _downloadLightspeed(version).then((lightspeed) async {
              await _saveLightspeed(lightspeed);
              return lightspeed;
            });
          }

          return lightspeed;
        }));
  }
}
