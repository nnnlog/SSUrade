import 'dart:typed_data';

import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_application/ssurade_application.dart';

@Singleton(as: LocalStorageSavePhotoPort)
class LocalStorageSavePhotoService implements LocalStorageSavePhotoPort {
  @override
  Future<void> savePhotoInGallery({required Uint8List data, required String name}) async {
    await ImageGallerySaver.saveImage(data, name: name);
  }
}
