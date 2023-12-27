import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ssurade/utils/toast.dart';
import 'package:tuple/tuple.dart';
import 'package:version/version.dart';

Future<Tuple3<String, String, String>> fetchAppVersion() async {
  String appVer = "", newVer = "", devVer = "";
  try {
    appVer = (await PackageInfo.fromPlatform()).version;

    var response = jsonDecode((await http.get(Uri.parse("https://api.github.com/repos/nnnlog/ssurade/releases"))).body);
    bool newVerFound = false, devVerFound = false;
    for (var obj in response) {
      if (obj["prerelease"] == false && !newVerFound) {
        newVerFound = true;
        devVerFound = true;

        newVer = obj["tag_name"].toString().substring(1); // cast to string and substring
      }
      if (obj["prerelease"] == true && !devVerFound) {
        devVerFound = true;
        devVer = obj["tag_name"].toString().substring(1); // cast to string and substring
      }
    }
    if (!newVerFound) newVer = "";
  } catch (e) {
    newVer = "";
    devVer = "";

    showToast("앱 최신 정보를 가져오지 못했어요.");
  }

  var appVerInstance = Version.parse(appVer);
  if (newVer != "" && appVerInstance >= Version.parse(newVer)) newVer = "";
  if (devVer != "" && appVerInstance >= Version.parse(devVer)) devVer = "";
  if (newVer != "" && devVer != "" && Version.parse(newVer) >= Version.parse(devVer)) devVer = "";
  return Tuple3(appVer, newVer, devVer);
}
