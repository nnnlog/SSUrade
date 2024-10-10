import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ssurade_application/domain/model/application/app_version.dart';
import 'package:ssurade_application/port/out/application/app_version_fetch_port.dart';
import 'package:version/version.dart';

@Singleton(as: AppVersionFetchPort)
class AppVersionFetchService implements AppVersionFetchPort {
  @override
  Future<AppVersion?> fetchAppVersion() async {
    String appVer = "", newVer = "", devVer = "", buildNum = "";
    try {
      await PackageInfo.fromPlatform().then((platform) {
        appVer = platform.version;
        buildNum = platform.buildNumber;
      });

      final response = jsonDecode((await http.get(Uri.parse("https://api.github.com/repos/nnnlog/ssurade/releases"))).body);

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

      return null;
    }

    final appVerInstance = Version.parse("$appVer+$buildNum");
    if (newVer != "" && appVerInstance >= Version.parse(newVer)) newVer = "";
    if (devVer != "" && appVerInstance >= Version.parse(devVer)) devVer = "";
    if (newVer != "" && devVer != "" && Version.parse(newVer) >= Version.parse(devVer)) devVer = "";

    return AppVersion(
      appVersion: appVer,
      newVersion: newVer,
      devVersion: devVer,
      buildNumber: buildNum,
    );
  }
}
