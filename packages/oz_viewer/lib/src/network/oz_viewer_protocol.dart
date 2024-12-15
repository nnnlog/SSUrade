import 'dart:typed_data';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:oz_viewer/src/error/protocol_exception.dart';
import 'package:oz_viewer/src/packet_stream/readable_packet_stream.dart';
import 'package:oz_viewer/src/packet_stream/writable_packet_stream.dart';

class OzViewerProtocol {
  OzViewerProtocol._();

  static Uri url = Uri.parse("https://office.ssu.ac.kr/oz70/server");

  static Uint8List encode(String path, Map<String, dynamic> arguments) {
    var data = WritablePacketStream(9545);
    data.writeUInt32(10001);
    data.writeString("oz.framework.cp.message.FrameworkRequestDataModule");

    ({
      'un': 'guest',
      'p': 'guest',
      's': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      'cv': '20140527',
      't': '',
      'i': '',
      'o': '',
      'z': '',
      'j': '',
      'd': '-1',
      'r': '1',
      'rv': '268435456',
      'xi': '',
      'xm': '',
      'xh': '',
      'pi': ''
    }).let((headers) {
      data.writeUInt32(headers.length);
      headers.forEach((key, value) {
        data.writeString(key);
        data.writeString(value);
      });
    });

    data.writeUInt32(380);
    data.writeString(path);
    data.writeUInt32(10000);
    data.writeString("/CM");
    data.writeBoolean(false);
    data.writeBoolean(false);
    data.writeString("");

    data.writeUInt32(arguments.length);
    arguments.forEach((key, value) {
      data.writeString(key);
      data.writeString(value);
    });

    data.writeUInt32(2);
    data.writeUInt32(32);
    data.writeUInt32(17);
    data.writeUInt32(0);
    data.writeUInt32(0);

    return data.toUint8List();
  }

  static Map<String, List<List<Map<String, String>>>> decode(Uint8List data) {
    var reader = ReadablePacketStream(ByteData.view(data.buffer));

    reader.readUInt32().let((ozVersion) {
      if (ozVersion != 10001) {
        throw ProtocolException("Invalid OZ Viewer version: $ozVersion, expected 10001");
      }
    });

    reader.readString(); // packet type

    reader.readUInt32().let((headerCount) {
      for (var i = 0; i < headerCount; i++) {
        reader.readString(); // header key
        reader.readString(); // header value
      }
    });

    reader.readUInt32().let((type) {
      if (type != 380) {
        throw ProtocolException("Invalid OZ Viewer type: $type, expected 380");
      }
    });

    reader.readBoolean().let((compressed) {
      if (compressed) {
        throw ProtocolException("Compressed OZ Viewer data is not supported");
      }
    });

    reader.readUInt32();
    reader.readUInt32().let((unknown) {
      if (unknown != 17) {
        throw ProtocolException("Invalid OZ Viewer unknown value: $unknown, expected 17");
      }
    });

    reader.readUTF(); // prefix
    reader.readUInt32(); // version
    reader.readUTF();
    reader.readUInt32();

    final headers = reader.readInt32().let((dataCount) {
      final headers = [];
      print(dataCount);

      for (var i = 0; i < dataCount; i++) {
        final a = reader.readUTF();
        final b = reader.readUTF();
        final c = reader.readUTF();

        final data1 = [], data2 = [], data3 = [];

        {
          final d = reader.readInt32();
          for (var j = 0; j < d; j++) {
            final e = reader.readInt32();
            final f = reader.readInt32();

            final g = reader.readUTF();
            final h = reader.readBoolean();

            String k = "";
            if (e == 2) {
              k = reader.readUTF();
            }

            data1.add([e, f, g, h, k]);
          }
        }

        {
          final d = reader.readInt32();

          if (d != 0) {
            final e = reader.readInt32();
            final f = reader.readInt32();
            final g = reader.readUTF();
            final h = reader.readBoolean();

            String k = "";
            if (e == 2) {
              k = reader.readUTF();
            }

            data2.addAll([e, f, g, h, k]);
          }
        }

        {
          final d = reader.readInt32();
          for (var j = 0; j < d; j++) {
            final e = reader.readInt32();
            final f = reader.readInt32();
            final g = reader.readUTF();

            data3.add([e, f, g]);
          }
        }

        headers.add([
          [a, b, c],
          data1,
          data2,
          data3,
        ]);
      }

      reader.readInt32(); // 4747

      for (var i = 0; i < headers.length; i++) {
        final offsets = [];
        for (var j = 0; j < headers[i][3].length; j++) {
          final current = [];
          for (var k = 0; k < headers[i][3][j][1]; k++) {
            final a = reader.readInt32();
            final b = reader.readInt32();
            current.add([a, b]);
          }
          offsets.add(current);
        }
        headers[i].add(offsets);
      }

      return headers;
    });

    final bodyReader = ReadablePacketStream(ByteData.view(data.sublist(reader.offset).buffer));

    final parsed = <String, List<List<Map<String, String>>>>{};
    for (var header in headers) {
      final results = <List<Map<String, String>>>[];

      for (var i = 0; i < (header[3] as List).length; i++) {
        final result = <Map<String, String>>[];
        for (var j = 0; j < (header[3][i][1] as int); j++) {
          final offset = header[4][i][j][1];

          if (offset != bodyReader.offset) {
            throw ProtocolException("Invalid OZ Viewer data offset: $offset, expected ${reader.offset}");
          }

          final current = <String, String>{};
          for (var definition in header[1]) {
            var dtype = definition[1];
            var dname = definition[2];

            var value;
            if (dtype == 12 || dtype == 1) {
              bodyReader.readUInt8(); // just move the offset
              value = bodyReader.readUTF();
            } else if (dtype == 91 || dtype == 92) {
              value = BigInt.zero;
              for (var i = 0; i < 2; i++) {
                value = (value << 32) + BigInt.from(bodyReader.readUInt32());
              }
              value = value.toString();
            } else if (dtype == 3) {
              value = double.tryParse(bodyReader.readUTF())?.toString();
            } else if (dtype == 2) {
              value = bodyReader.readUTF();
            } else if (dtype == 4) {
              bodyReader.readUInt8(); // just move the offset
              value = bodyReader.readUInt32().toString();
            } else {
              throw ProtocolException("Invalid OZ Viewer data type: $dtype");
            }

            current[dname] = value;
          }

          result.add(current);
        }

        results.add(result);
      }

      parsed[header[0][0]] = results;
    }

    return parsed;
  }
}
