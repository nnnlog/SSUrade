import 'dart:concurrent';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@singleton
class AssetLoaderService {
  final Map<String, String> _cache = {};
  final Mutex _mutex = Mutex();

  AssetLoaderService();

  Future<String> loadAsset(String path) async {
    return _mutex.runLocked(() async {
      if (_cache.containsKey(path)) {
        return _cache[path]!;
      }

      return _cache[path] = await rootBundle.loadString("asset/$path");
    });
  }
}
