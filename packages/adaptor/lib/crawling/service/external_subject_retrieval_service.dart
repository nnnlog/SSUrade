import 'dart:collection';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:df/df.dart';
import 'package:injectable/injectable.dart';
import 'package:parallel_worker/parallel_worker.dart';
import 'package:ssurade_adaptor/crawling/job/main_thread_crawling_job.dart';
import 'package:ssurade_adaptor/crawling/webview/web_view_client.dart';
import 'package:ssurade_adaptor/crawling/webview/web_view_client_service.dart';
import 'package:ssurade_application/ssurade_application.dart';

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
              name: subject["subject_name"].let((str) {
                if (str == "성적 미입력") {
                  return "";
                }
                return str;
              }),
              credit: double.parse(subject["credit"]),
              grade: subject["grade_symbol"],
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
        // return await _getSemesterSubjectsFromOldVersion(client, yearSemester);
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
          subjects.add(subject.copyWith(detail: detail));
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

  // 이수구분별 성적표 조회
  List<DataFrame> _parseOZViewerData(String raw) {
    const String separator = "|||||";
    List<DataFrame> ret = [];

    var list = raw.split("\n").map((e) => e.split(separator).map((e) => e.trim()).toList()).toList(); // 값에 \n이 없다고 가정함. (강의 계획서에는 \n이 있어서 이 방법으로 불가능)
    int keyPrev = -1;
    DataFrame df = DataFrame();
    for (var value in list) {
      if (keyPrev != value.length) {
        if (df.length > 0) {
          ret.add(df);
          df = DataFrame();
        }
        keyPrev = value.length;
        df.setColumns(value.map((e) => DataFrameColumn(name: e, type: String)).toList());
      } else {
        df.addRecords(value);
      }
    }
    if (df.length > 0) {
      ret.add(df);
    }
    return ret;
  }

  Future<SemesterSubjectsManager> _getAllSemesterSubjectsByCategory(WebViewClient client) async {
    final String gradeUrl = await run(() async {
      await client.loadPage("https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW8030n?sap-language=KO");
      return (await client.execute("return await ssurade.crawl.getGradeViewerURL().catch(() => {});"));
    });

    final String rawData = await run(() async {
      await client.loadPage(gradeUrl);
      return await client.execute("return await ssurade.crawl.getGradeFromViewer();");
    });

    final data = _parseOZViewerData(rawData)[0];
    return SemesterSubjectsManager(
      data: SplayTreeMap.fromIterable(
        data.rows.map((rowData) {
          Map<String, String> row = {};
          for (var key in rowData.keys) {
            row[key] = rowData[key] as String;
          }

          final rawKey = row["HUKGI"]!.split("―");
          final key = YearSemester(
            year: int.parse(rawKey[0]),
            semester: Semester.parse("${rawKey[1]}학기"),
          );

          final subject = Subject(
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
          );

          return SemesterSubjects(
            subjects: SplayTreeMap.fromIterable([subject], key: (subject) => subject.code),
            currentSemester: key,
            semesterRanking: Ranking.unknown,
            totalRanking: Ranking.unknown,
          );
        }),
        key: (subject) => subject.code,
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
    return MainThreadCrawlingJob(() async {
      final clients = await Future.wait(List.filled(_webViewCount, null).map((_) {
        return _webViewClientService.create();
      }).toList());

      final syllabusClient = clients.removeLast();

      final results = await Future.wait([
        syllabusClient.loadPage(_semesterGradeUrl).then<SemesterSubjectsManager>((_) => _getAllSemesterSubjectsByCategory(syllabusClient)),
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
          ).result.then((res) => res.whereType<SemesterSubjects>().toList()).then<SemesterSubjectsManager>((subjects) async {
            await Future.wait(clients.map((client) => client.loadPage(_semesterGradeOldVersionUrl)));

            final research = semesters.where((semester) => subjects.any((element) => element.currentSemester == semester)).toList();

            final researchedSubjects = await ParallelWorker(
              jobs: research.map((yearSemester) {
                return (client) => _getSemesterSubjectsFromOldVersion(client, yearSemester);
              }).toList(),
              workers: clients,
            ).result.then((subjects) => subjects.whereType<SemesterSubjects>().toList());

            return (subjects + researchedSubjects).let((it) {
              return SemesterSubjectsManager(
                data: SplayTreeMap.fromIterable(it, key: (subject) => subject.currentSemester),
                state: SubjectState.semester,
              );
            });
          });
        })(),
      ]);

      syllabusClient.dispose();
      clients.forEach((client) {
        client.dispose();
      });

      return SemesterSubjectsManager.merge(results[0], results[1]);
    });
  }

  @override
  Job<SemesterSubjects?> retrieveSemesterSubjects(YearSemester yearSemester, {bool includeDetail = true}) {
    return MainThreadCrawlingJob(() async {
      final semesterClient = await _webViewClientService.create(), categoryClient = await _webViewClientService.create();

      final results = await Future.wait([
        semesterClient.loadPage(_semesterGradeUrl).then<SemesterSubjects?>((_) async {
          final result = await _getSemesterSubjects(semesterClient, yearSemester, includeDetail: includeDetail);
          if (result == null) {
            return await _getSemesterSubjectsFromOldVersion(semesterClient, yearSemester);
          }
          return result;
        }),
        categoryClient.loadPage(_categoryGradeUrl).then<SemesterSubjectsManager>((_) => _getAllSemesterSubjectsByCategory(categoryClient)),
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
    });
  }
}
