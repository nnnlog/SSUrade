import 'dart:typed_data';

class WritablePacketStream {
  ByteData _byteData;
  int _offset = 0;

  WritablePacketStream(int length) : _byteData = ByteData(length);

  void writeUInt8(int value) {
    _byteData.setUint8(_offset++, value);
  }

  void writeUInt16(int value) {
    _byteData.setUint16(_offset, value);
    _offset += 2;
  }

  void writeUInt32(int value) {
    _byteData.setUint32(_offset, value);
    _offset += 4;
  }

  void writeString(String value) {
    writeUInt32(value.length);

    for (int i = 0; i < value.length; i++) {
      final code = value.codeUnitAt(i);
      writeUInt8(code >> 8);
      writeUInt8(code & 0xFF);
    }
  }

  void writeBoolean(bool value) {
    writeUInt8(value ? 255 : 0);
  }

  Uint8List toUint8List() {
    return _byteData.buffer.asUint8List();
  }
}
