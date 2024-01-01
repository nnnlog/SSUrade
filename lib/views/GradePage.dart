import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:screenshot/screenshot.dart';
import 'package:ssurade/components/CustomAppBar.dart';
import 'package:ssurade/components/GradeLogo.dart';
import 'package:ssurade/components/GradePageHeader.dart';
import 'package:ssurade/components/SubjectWidget.dart';
import 'package:ssurade/crawling/common/Crawler.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/etc/Progress.dart';
import 'package:ssurade/types/semester/YearSemester.dart';
import 'package:ssurade/types/subject/SemesterSubjects.dart';
import 'package:ssurade/types/subject/SemesterSubjectsManager.dart';
import 'package:ssurade/types/subject/state.dart';
import 'package:ssurade/utils/toast.dart';

class GradePage extends StatefulWidget {
  const GradePage({super.key});

  @override
  State<StatefulWidget> createState() => _GradePageState();
}

class _GradePageState extends State<GradePage> {
  late SemesterSubjects _semesterSubjects;
  final RefreshController _refreshController = RefreshController();

  final ScreenshotController _imageController = ScreenshotController();

  GradeProgress _progress = GradeProgress.init;
  final Set<YearSemester> _lockedForRefresh = {};

  bool _exportImage = false;
  bool _showRanking = true;
  bool _showSubjectInfo = true;

  void callbackSelectSubject(YearSemester value) {
    setState(() {
      _semesterSubjects = globals.semesterSubjectsManager.data[value]!;
      // _search = value;
      // _subjects = globals.subjectDataCache.data[_search]!;
    });
  }

  Future<void> refreshCurrentGrade() async {
    var search = _semesterSubjects.currentSemester;
    if (_lockedForRefresh.contains(search)) return;
    _lockedForRefresh.add(search);

    showToast("${search.year}학년도 ${search.semester.displayName} 성적을 불러오는 중이에요...");
    showToast("불러오는 시간이 오래 걸릴 수 있어요.");

    try {
      late SemesterSubjects data1;
      late Map<String, Map<String, String>> data2;

      var futures = <Future>[];
      futures.add(Crawler.singleGradeBySemester(search).execute().then((value) => data1 = value));
      futures.add(Crawler.semesterSubjectDetailGrade(_semesterSubjects).execute().then((value) => data2 = value).then((value) {
        if (_semesterSubjects.currentSemester.toString() == search.toString()) {
          showToast("성적 상세 정보를 불러왔어요.");
        }
      }));

      await Future.wait(futures);

      for (var subjectCode in data2.keys) {
        data1.subjects[subjectCode]?.detail = data2[subjectCode]!;
      }

      if (globals.semesterSubjectsManager.data.containsKey(search)) {
        globals.semesterSubjectsManager.data[search] = SemesterSubjects.merge(data1, globals.semesterSubjectsManager.data[search]!, STATE_SEMESTER, globals.semesterSubjectsManager.state)!;
      } else {
        globals.semesterSubjectsManager.data[search] = data1;
      }

      globals.gradeUpdateEvent.broadcast();
      globals.semesterSubjectsManager.saveFile();

      if (!mounted) return;
      if (search != _semesterSubjects.currentSemester) return;

      setState(() {
        _semesterSubjects = globals.semesterSubjectsManager.data[search]!;
      });

      showToast("${search.year}학년도 ${search.semester.displayName} 성적을 불러왔어요.");
    } catch (_) {
      if (mounted) {
        showToast("${search.year}학년도 ${search.semester.displayName} 성적을 불러오지 못했어요.");
      }
    } finally {
      _lockedForRefresh.remove(search);
    }
  }

  refreshCurrentGradeWithPull() async {
    await refreshCurrentGrade();

    _refreshController.loadComplete();
    _refreshController.refreshCompleted();
  }

  SemesterSubjects getMainSemester() {
    var ret = globals.semesterSubjectsManager.data.values.last;

    // 계절학기 수강 신청이 시작되면 본학기 성적 입력 기간이더라도 계절학기 성적도 함께 보임
    for (var data in globals.semesterSubjectsManager.data.values) {
      bool unknownGrade = false;
      for (var subject in data.subjects.values) {
        if (GradeLogo.parse(subject.grade) == GradeLogo.unknown) {
          // TODO: remove dependency related to widget
          unknownGrade = true;
          break;
        }
      }

      if (unknownGrade) {
        ret = data;
        break;
      }
    }

    return ret;
  }

  void updateGradeEventHandler(_) {
    setState(() {
      var data = globals.semesterSubjectsManager.data;
      if (data.containsKey(_semesterSubjects.currentSemester)) {
        _semesterSubjects = data[_semesterSubjects.currentSemester]!;
      } else {
        _semesterSubjects = getMainSemester();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    (() async {
      bool needRefresh = true;
      if (globals.semesterSubjectsManager.isEmpty) {
        needRefresh = false;

        SemesterSubjectsManager res;
        try {
          res = await Crawler.allGrade().execute();
        } catch (_) {
          if (mounted) {
            Navigator.pop(context);
          }
          showToast("성적 정보를 가져오지 못했어요.\n다시 시도해주세요.");
          return;
        }

        globals.semesterSubjectsManager = res;
        globals.semesterSubjectsManager.saveFile(); // saving file does not need await

        globals.gradeUpdateEvent.broadcast();

        {
          showToast("성적 상세 정보를 불러오는 중이에요...");

          var value = globals.semesterSubjectsManager;
          for (var key in value.data.keys) {
            Crawler.semesterSubjectDetailGrade(value.data[key]!).execute().then((value) {
              for (var subjectCode in value.keys) {
                if (value[subjectCode]?.isNotEmpty == true) {
                  globals.semesterSubjectsManager.data[key]?.subjects[subjectCode]?.detail = value[subjectCode]!;
                  globals.semesterSubjectsManager.saveFile();

                  globals.gradeUpdateEvent.broadcast();
                }
              }

              if (mounted && key.toString() == _semesterSubjects.currentSemester.toString()) {
                showToast("성적 상세 정보를 불러왔어요.");
              }
            });
          }
        }
      }

      if (globals.semesterSubjectsManager.isEmpty) {
        if (mounted) {
          Navigator.pop(context);
        }
        showToast("성적 정보를 불러오지 못했거나 성적 정보가 없어요.");
        return;
      }

      globals.gradeUpdateEvent.subscribe(updateGradeEventHandler);

      setState(() {
        _semesterSubjects = getMainSemester();
        _progress = GradeProgress.finish;
      });

      if (needRefresh && globals.setting.refreshGradeAutomatically) {
        refreshCurrentGrade();
      }
    })();
  }

  @override
  void dispose() {
    super.dispose();

    globals.gradeUpdateEvent.unsubscribe(updateGradeEventHandler);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("학기별 성적 조회"),
      backgroundColor: globals.isLightMode ? (_progress == GradeProgress.init ? null : const Color.fromRGBO(241, 242, 245, 1)) : null,
      body: _progress == GradeProgress.init
          ? const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LinearProgressIndicator(),
                    SizedBox(
                      width: 1,
                      height: 15,
                    ),
                    Text("전체 학기 성적을 불러오고 있어요..."),
                  ],
                ),
              ),
            )
          : SmartRefresher(
              controller: _refreshController,
              onRefresh: refreshCurrentGradeWithPull,
              // onLoading: refreshCurrentGradeWithPull,
              child: SingleChildScrollView(
                child: Screenshot(
                  controller: _imageController,
                  child: Container(
                    color: globals.isLightMode ? (_progress == GradeProgress.init ? null : const Color.fromRGBO(241, 242, 245, 1)) : null,
                    child: Column(
                      children: <Widget>[
                            GradePageHeader(_semesterSubjects, callbackSelectSubject, refreshCurrentGrade, _exportImage, _showRanking),
                          ] +
                          (_semesterSubjects.subjects.values.toList()..sort((a, b) => a.compareTo(b))).map((e) => SubjectWidget(e, _exportImage, _showSubjectInfo)).toList(),
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: _progress == GradeProgress.finish
          ? FloatingActionButton(
              onPressed: () async {
                _showRanking = true;
                _showSubjectInfo = true;

                showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(builder: (BuildContext context, StateSetter setStateDialog) {
                        return Dialog(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(25, 25, 20, 15),
                            child: IntrinsicHeight(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "이미지로 내보내기",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SwitchListTile(
                                    value: _showRanking,
                                    onChanged: (value) {
                                      setStateDialog(() {
                                        _showRanking = value;
                                      });
                                    },
                                    dense: true,
                                    title: const Text("석차"),
                                  ),
                                  SwitchListTile(
                                    value: _showSubjectInfo,
                                    onChanged: (value) {
                                      setStateDialog(() {
                                        _showSubjectInfo = value;
                                      });
                                    },
                                    dense: true,
                                    title: const Text("과목 정보"),
                                  ),
                                  Row(
                                    children: [
                                      const Spacer(),
                                      TextButton(
                                          onPressed: () async {
                                            setState(() {
                                              _exportImage = true;
                                            });
                                            final bytes = await _imageController.capture();
                                            await ImageGallerySaver.saveImage(bytes!, name: "ssurade_${_semesterSubjects.currentSemester.display}-${DateTime.now().toLocal().millisecondsSinceEpoch}");

                                            setState(() {
                                              _exportImage = false;
                                            });

                                            showToast("이미지를 저장했어요.");
                                          },
                                          child: const Text("내보내기"))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    });
              },
              child: const Icon(Icons.image),
            )
          : null,
    );
  }
}
