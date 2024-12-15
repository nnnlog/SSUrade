import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:oz_viewer/src/network/oz_viewer_protocol.dart';

class OzViewerRequest {
  OzViewerRequest._();

  static Future<Map<String, List<List<Map<String, String>>>>> _request(Uint8List body) async {
    final response = await http.post(OzViewerProtocol.url, body: body);
    return OzViewerProtocol.decode(response.bodyBytes);
  }

  static Future<List<Map<String, String>>> getGradeByCategory(String id) async {
    final body = OzViewerProtocol.encode("zcmw8030secu.odi", {
      "ADMIN": "000000000000",
      "UNAME": id,
    });
    final response = await _request(body);
    return response['ITAB']![0];
  }
}
