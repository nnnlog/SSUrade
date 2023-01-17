import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ssurade/filesystem/FileSystem.dart';
import 'package:ssurade/types/Semester.dart';
import 'package:ssurade/types/YearSemester.dart';

int lastUpdated = -1;

Future<int> _getLastUpdatedTime() async {
  if (lastUpdated != -1) return lastUpdated;
  lastUpdated = int.parse((await http.get(Uri.parse("https://raw.githubusercontent.com/nnnlog/ssurade-subject-pf/master/info.txt"))).body);
  return lastUpdated;
}

bool _called = false;
late Future<void> _waitForCheck;

Future<void> _checkUpdate() async {
  if (_called) return _waitForCheck;
  _called = true;
  return _waitForCheck = Future(() async {
    await _getLastUpdatedTime();

    await mkdir("pf_subjects");

    int lastSaved;
    if (await existFile("pf_subjects/info.txt")) {
      lastSaved = int.parse((await readFile("pf_subjects/info.txt"))!);
    } else {
      lastSaved = -1;
    }

    if (lastSaved < lastUpdated) {
      await rmdir("pf_subjects"); // remove all
      await mkdir("pf_subjects");

      await writeFile("pf_subjects/info.txt", lastUpdated.toString());
    }
  });
}

Map<YearSemester, Map<String, bool>> _cache = {};

Future<Map<String, bool>> getPassFailSubjects(
  YearSemester info, {
  useCache = true,
}) async {
  if (_cache.containsKey(info)) return _cache[info]!;

  await _checkUpdate(); // TODO: check internet connection

  List<dynamic> tmp;
  if (useCache && await existFile("pf_subjects/pf_${info.year}-${info.semester.name}.json")) {
    tmp = jsonDecode((await readFile("pf_subjects/pf_${info.year}-${info.semester.name}.json"))!);
  } else {
    var res =
        await http.get(Uri.parse("https://raw.githubusercontent.com/nnnlog/ssurade-subject-pf/master/pf_${info.year}-${info.semester.name}.json"));
    if (res.statusCode != 200) {
      return {};
    }
    tmp = jsonDecode(res.body);
    await writeFile("pf_subjects/pf_${info.year}-${info.semester.name}.json", jsonEncode(tmp));
  }

  _cache[info] = {};
  for (var element in tmp) {
    _cache[info]![element] = true;
  }

  return _cache[info]!;
}
