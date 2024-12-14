import 'dart:convert';
import 'dart:typed_data';

class ReadablePacketStream {
  ByteData _byteData;
  int _offset = 0;

  ReadablePacketStream(this._byteData);

  int readUInt8() {
    return _byteData.getUint8(_offset++);
  }

  int readUInt16() {
    final value = _byteData.getUint16(_offset);
    _offset += 2;
    return value;
  }

  int readUInt32() {
    final value = _byteData.getUint32(_offset);
    _offset += 4;
    return value;
  }

  int readInt32() {
    final value = _byteData.getInt32(_offset);
    _offset += 4;
    return value;
  }

  String readString() {
    final length = readUInt32();

    String value = '';
    for (int i = 0; i < length; i++) {
      var code = readUInt8() << 8;
      code += readUInt8();

      if (code > 0) {
        value += String.fromCharCode(code);
      }
    }

    return value;
  }

  String readUTF() {
    var length = readUInt16();

    if (length == 65535) {
      length = readUInt32();
    }

    Uint8List bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = readUInt8();
    }

    return utf8.decode(bytes);
  }

  bool readBoolean() {
    return readUInt8() == 255;
  }

  bool eof() {
    return _offset >= _byteData.lengthInBytes;
  }

  int get offset => _offset;
}
