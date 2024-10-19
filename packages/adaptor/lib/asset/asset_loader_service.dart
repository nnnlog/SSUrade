import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:mutex/mutex.dart';

@singleton
class AssetLoaderService {
  final Map<String, String> _cache = {};
  final Mutex _mutex = Mutex();

  AssetLoaderService();

  Future<String> loadAsset(String path) async {
    return _mutex.protect(() async {
      if (_cache.containsKey(path)) {
        return _cache[path]!;
      }

      return _cache[path] = await rootBundle.loadString("assets/$path");
    });
  }
}
