// import 'package:dart_scope_functions/dart_scope_functions.dart';
// import 'package:http/http.dart' as http;
// import 'package:ssurade_application/ssurade_application.dart';
//
// class ExternalLightspeedRetrievalService implements ExternalLightspeedRetrievalPort {
//   @override
//   Future<Lightspeed> retrieveLightspeed(String version) async {
//     return (await http.get(Uri.parse("https://ecc.ssu.ac.kr/sap/public/bc/ur/nw7/js/dbg/lightspeed.js"))).body.let((it) {
//       return Lightspeed(version: version, data: it.replaceAll("oObject && aMethods", "false"));
//     });
//   }
// }
