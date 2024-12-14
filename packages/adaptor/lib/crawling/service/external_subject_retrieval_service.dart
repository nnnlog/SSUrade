import 'dart:collection';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:packet_stream/packet_stream.dart';
import 'package:parallel_worker/parallel_worker.dart';
import 'package:ssurade_adaptor/crawling/constant/crawling_timeout.dart';
import 'package:ssurade_adaptor/crawling/job/main_thread_crawling_job.dart';
import 'package:ssurade_adaptor/crawling/webview/web_view_client.dart';
import 'package:ssurade_adaptor/crawling/webview/web_view_client_service.dart';
import 'package:ssurade_application/ssurade_application.dart';
import 'package:http/http.dart' as http;

@Singleton(as: ExternalSubjectRetrievalPort)
class ExternalSubjectRetrievalService implements ExternalSubjectRetrievalPort {
  WebViewClientService _webViewClientService;

  ExternalSubjectRetrievalService(this._webViewClientService);

  // 학기별 성적 조회
  Future<SemesterSubjects?> _getSemesterSubjectsFromOldVersion(WebViewClient client, YearSemester yearSemester) async {
    return client.execute("return await ssurade.crawl.getGradeBySemesterOldVersion('${yearSemester.year}', '${yearSemester.semester.rawIntegerValue}').catch(() => {});").then((res) {
      if (res == null || !(res["subjects"] is List)) {
        return null;
      }

      return SemesterSubjects(
        subjects: SplayTreeMap.fromIterable(
            res["subjects"].map((subject) {
              return Subject(
                code: subject["subject_code"],
                name: subject["subject_name"],
                credit: 0,
                grade: "",
                professor: subject["professor"],
                category: "",
                detail: {},
                info: "",
                isPassFail: false,
                score: "",
              );
            }),
            key: (subject) => subject.code),
        currentSemester: yearSemester,
        semesterRanking: Ranking.unknown,
        totalRanking: Ranking.unknown,
      );
    });
  }

  Future<SemesterSubjects?> _getSemesterSubjects(WebViewClient client, YearSemester yearSemester, {bool includeDetail = true}) async {
    return client
        .execute(
            "return await ssurade.crawl.getGradeBySemester('${yearSemester.year}', '${yearSemester.semester.rawIntegerValue}', '${yearSemester.semester.rawTextContent}', $includeDetail).catch(() => {});")
        .then((res) async {
      if (res == null || !(res["subjects"] is List)) {
        return null;
      }

      final semesterSubjects = SemesterSubjects(
        subjects: SplayTreeMap.fromIterable(
          res["subjects"].map((subject) {
            return Subject(
              code: subject["subject_code"],
              name: subject["subject_name"],
              credit: double.parse(subject["credit"]),
              grade: (subject["grade_symbol"] as String).let((str) {
                if (str == "성적 미입력") {
                  return "";
                }
                return str;
              }),
              professor: subject["professor"],
              category: "",
              detail: {},
              info: "",
              isPassFail: false,
              score: subject["grade_score"],
            );
          }),
          key: (subject) => subject.code,
        ),
        currentSemester: yearSemester,
        semesterRanking: Ranking.parse(res["rank"]?["semester_rank"] ?? ""),
        totalRanking: Ranking.parse(res["rank"]?["total_rank"] ?? ""),
      );

      if (semesterSubjects.subjects.isEmpty) {
        return null;
      }

      if (includeDetail) {
        var subjects = [];
        for (var subject in semesterSubjects.subjects.values) {
          final detail =
              await client.execute("return await ssurade.crawl.getGradeDetail('${yearSemester.year}', '${yearSemester.semester.rawIntegerValue}', '${subject.code}').catch(() => {});").then((res) {
            if (res == null) {
              return {"-": "성적이 입력되지 않았거나 상세 정보가 없어요."};
            }
            return res;
          });
          subjects.add(subject.copyWith(detail: Map<String, String>.from(detail)));
        }

        return semesterSubjects.copyWith(
          subjects: SplayTreeMap.fromIterable(subjects, key: (subject) => subject.code),
        );
      }

      return semesterSubjects;
    });
  }

  Future<Set<YearSemester>> _getCompletedSemesters(WebViewClient client) async {
    return client.execute("return await ssurade.crawl.getGradeSemesterList().catch(() => {});").then((res) {
      if (!(res is List)) {
        return Set();
      }

      return Set.from(res.map((e) {
        return YearSemester(
          year: int.parse(e['year']),
          semester: Semester.parse(e['semester']),
        );
      }));
    });
  }

  Future<List<Map<String, String>>> _parseOZViewerData(Uint8List data) async {
    var reader = ReadablePacketStream(ByteData.view(data.buffer));

    reader.readUInt32().let((ozVersion) {
      if (ozVersion != 10001) {
        throw UnexpectedException("Invalid OZ Viewer version: $ozVersion, expected 10001");
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
        throw UnexpectedException("Invalid OZ Viewer type: $type, expected 380");
      }
    });

    reader.readBoolean().let((compressed) {
      if (compressed) {
        throw UnexpectedException("Compressed OZ Viewer data is not supported");
      }
    });

    reader.readUInt32();
    reader.readUInt32().let((unknown) {
      if (unknown != 17) {
        throw UnexpectedException("Invalid OZ Viewer unknown value: $unknown, expected 17");
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
            throw UnexpectedException("Invalid OZ Viewer data offset: $offset, expected ${reader.offset}");
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
              throw UnexpectedException("Invalid OZ Viewer data type: $dtype");
            }

            current[dname] = value;
          }

          result.add(current);
        }

        results.add(result);
      }

      parsed[header[0][0]] = results;
    }

    return parsed['ITAB']![0];
  }

  Future<List<Map<String, String>>> _getOZViewerData(String id) async {
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
    data.writeString("zcmw8030secu.odi");
    data.writeUInt32(10000);
    data.writeString("/CM");
    data.writeBoolean(false);
    data.writeBoolean(false);
    data.writeString("");

    ({
      "ADMIN": "000000000000",
      "UNAME": id,
    }).let((parameters) {
      data.writeUInt32(parameters.length);
      parameters.forEach((key, value) {
        data.writeString(key);
        data.writeString(value);
      });
    });

    data.writeUInt32(2);
    data.writeUInt32(32);
    data.writeUInt32(17);
    data.writeUInt32(0);
    data.writeUInt32(0);

    final response = await http.post(Uri.parse("https://office.ssu.ac.kr/oz70/server"), body: data.toUint8List());

    return _parseOZViewerData(response.bodyBytes);
  }

  Future<SemesterSubjectsManager> _getAllSemesterSubjectsByCategory(WebViewClient client) async {
    final String gradeUrl = await run(() async {
      await client.loadPage(_categoryGradeUrl);
      return (await client.execute("return await ssurade.crawl.getGradeViewerURL().catch(() => {});"));
    });

    final data = await Uri.parse(gradeUrl).queryParameters["pValue"]?.split(",")[1].let((id) async {
      return await _getOZViewerData(id);
    });

    if (data == null) {
      throw UnexpectedException("Invalid OZ Viewer URL");
    }

    return SemesterSubjectsManager(
      data: SplayTreeMap<YearSemester, SemesterSubjects>.fromIterable(
        groupBy(data.map((rowData) {
          Map<String, String> row = {};
          for (var key in rowData.keys) {
            row[key] = rowData[key] as String;
          }

          final rawKey = row["HUKGI"]!.split("―");
          final key = YearSemester(
            year: int.parse(rawKey[0]),
            semester: Semester.parse("${rawKey[1]}학기"),
          );

          return (
            key,
            Subject(
              code: row["SM_ID"]!,
              // FORMAT: 21501015
              name: "",
              // SM_TEXT에 존재하지만, 교선에 교선 분류명도 함께 있음
              credit: double.parse(row["CPATTEMP"]!),
              grade: row["GRADE"]!,
              // 성적 기호
              score: row["GRADESYMBOL"]!,
              // 최종 점수 (근데 이름이 왜 이래)
              professor: "",
              category: row["COMPL_TEXT"]!,
              isPassFail: row["GRADESCALE"]! == "PF",
              // otherwise, '100P'
              info: row["SM_INFO"]!,
              // 해당 과목의 졸업 사정 정보 (재수강되어 졸업 사정되지 않는 과목 / 영어 강의 등..)
              detail: {},
            )
          );
        }), (data) => data.$1).entries.map((entry) {
          return SemesterSubjects(
            subjects: SplayTreeMap.fromIterable(entry.value.map((value) => value.$2), key: (subject) => subject.code),
            currentSemester: entry.key,
            semesterRanking: Ranking.unknown,
            totalRanking: Ranking.unknown,
          );
        }),
        key: (semesters) => (semesters as SemesterSubjects).currentSemester,
      ),
      state: SubjectState.category,
    );
  }

  static String get _semesterGradeUrl => "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMB3W0017?sap-language=KO";

  static String get _semesterGradeOldVersionUrl => "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW5002?sap-language=KO";

  static String get _categoryGradeUrl => "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW8030n?sap-language=KO";

  static int get _webViewCount => 10;

  @override
  Job<SemesterSubjectsManager?> retrieveAllSemesterSubjects({bool includeDetail = true}) {
    return MainThreadCrawlingJob(CrawlingTimeout.grade, () async {
      final clients = await Future.wait(List.filled(_webViewCount, null).map((_) {
        return _webViewClientService.create();
      }).toList());
      final categoryClient = clients.removeLast();

      return run(() async {
        final results = await Future.wait([
          _getAllSemesterSubjectsByCategory(categoryClient),
          (() async {
            await Future.wait(clients.map((client) => client.loadPage(_semesterGradeUrl)));

            final semesters = await _getCompletedSemesters(clients.first);

            run(() {
              var year = DateTime.now().year, month = DateTime.now().month;
              if (month <= DateTime.february) {
                year--;
              }
              for (var semester in Semester.values) {
                semesters.add(YearSemester(year: year, semester: semester));
              }
            });

            return await ParallelWorker(
              jobs: semesters.map((yearSemester) {
                return (client) => _getSemesterSubjects(client, yearSemester, includeDetail: includeDetail);
              }).toList(),
              workers: clients,
            ).result.then((res) => res.whereType<SemesterSubjects>().toList()).then<SemesterSubjectsManager>((semesterSubjects) async {
              await Future.wait(clients.map((client) => client.loadPage(_semesterGradeOldVersionUrl)));

              final research = semesters.where((semester) => !semesterSubjects.any((element) => element.currentSemester == semester)).toList();

              final researchedSubjects = await ParallelWorker(
                jobs: research.map((yearSemester) {
                  return (client) => _getSemesterSubjectsFromOldVersion(client, yearSemester);
                }).toList(),
                workers: clients,
              ).result.then((subjects) => subjects.whereType<SemesterSubjects>().toList());

              return (semesterSubjects + researchedSubjects).let((it) {
                return SemesterSubjectsManager(
                  data: SplayTreeMap.fromIterable(it, key: (subject) => subject.currentSemester),
                  state: SubjectState.semester,
                );
              });
            });
          })(),
        ]);

        return SemesterSubjectsManager.merge(results[0], results[1]);
      }).whenComplete(() {
        categoryClient.dispose();
        clients.forEach((client) {
          client.dispose();
        });
      });
    });
  }

  @override
  Job<SemesterSubjects?> retrieveSemesterSubjects(YearSemester yearSemester, {bool includeDetail = true}) {
    return MainThreadCrawlingJob(CrawlingTimeout.grade, () async {
      final semesterClient = await _webViewClientService.create(), categoryClient = await _webViewClientService.create();

      return run(() async {
        final results = await Future.wait([
          semesterClient.loadPage(_semesterGradeUrl).then<SemesterSubjects?>((_) async {
            final result = await _getSemesterSubjects(semesterClient, yearSemester, includeDetail: includeDetail);
            if (result == null) {
              await semesterClient.loadPage(_semesterGradeOldVersionUrl);
              return await _getSemesterSubjectsFromOldVersion(semesterClient, yearSemester);
            }
            return result;
          }),
          _getAllSemesterSubjectsByCategory(categoryClient),
        ]);

        final currentSemester = results.whereType<SemesterSubjects>().firstOrNull;
        final category = results.whereType<SemesterSubjectsManager>().first;

        if (currentSemester == null) {
          return null;
        }

        final currentSemesterInCategory = category.data[currentSemester.currentSemester];
        if (currentSemesterInCategory == null) {
          return currentSemester;
        }

        return SemesterSubjects.merge(currentSemester, currentSemesterInCategory, SubjectState.semester, SubjectState.category);
      }).whenComplete(() {
        semesterClient.dispose();
        categoryClient.dispose();
      });
    });
  }
}
