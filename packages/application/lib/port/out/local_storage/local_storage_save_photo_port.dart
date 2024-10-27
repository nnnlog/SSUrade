import 'dart:typed_data';

abstract interface class LocalStorageSavePhotoPort {
  Future<void> savePhotoInGallery({
    required Uint8List data,
    required String name,
  });
}
