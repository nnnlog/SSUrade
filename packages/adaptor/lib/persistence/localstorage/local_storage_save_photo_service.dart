import 'dart:typed_data';

import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_application/ssurade_application.dart';

final _imageSaver = ImageGallerySaver();

@Singleton(as: LocalStorageSavePhotoPort)
class LocalStorageSavePhotoService implements LocalStorageSavePhotoPort {
  @override
  Future<void> savePhotoInGallery({required Uint8List data, required String name}) async {
    await _imageSaver.saveImage(data);
  }
}
