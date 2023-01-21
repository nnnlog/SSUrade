import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:screenshot/screenshot.dart';
import 'package:ssurade/components/CustomAppBar.dart';
import 'package:ssurade/components/GradePageHeader.dart';
import 'package:ssurade/components/SubjectWidget.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/Progress.dart';
import 'package:ssurade/types/Semester.dart';
import 'package:ssurade/types/YearSemester.dart';
import 'package:ssurade/types/subject/SemesterSubjects.dart';
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
  bool _lockedForRefresh = false;

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
    if (_lockedForRefresh) return;
    _lockedForRefresh = true;

    var search = _semesterSubjects.currentSemester;
    showToast("${search.year}학년도 ${search.semester.name} 성적을 불러옵니다.");

    SemesterSubjects? data = (await globals.setting.uSaintSession.getGrade(search));
    if (!mounted) return;
    if (data == null) {
      showToast("${search.year}학년도 ${search.semester.name} 성적을 불러오지 못했습니다.");
      return;
    }

    globals.semesterSubjectsManager.data[search] = data;
    globals.semesterSubjectsManager.saveFile();

    setState(() {
      _semesterSubjects = data;
    });

    showToast("${search.year}학년도 ${search.semester.name} 성적을 불러왔습니다.");
    _lockedForRefresh = false;
  }

  refreshCurrentGradeWithPull() async {
    await refreshCurrentGrade();

    _refreshController.loadComplete();
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();

    (() async {
      bool needRefresh = true;
      if (globals.semesterSubjectsManager.isEmpty) {
        needRefresh = false;

        var res = await globals.setting.uSaintSession.getAllGrade();
        if (res == null) {
          if (mounted) {
            Navigator.pop(context);
          }
          showToast("성적 정보를 가져오지 못했습니다.\n다시 시도해주세요.");
          return;
        }

        globals.semesterSubjectsManager = res;
        globals.semesterSubjectsManager.saveFile(); // saving file does not need await
      }

      if (globals.semesterSubjectsManager.isEmpty) {
        if (mounted) {
          Navigator.pop(context);
        }
        showToast("성적 정보가 없습니다.");
        return;
      }

      setState(() {
        _semesterSubjects = globals.semesterSubjectsManager.data.values.last;
        _progress = GradeProgress.finish;
      });

      if (needRefresh && globals.setting.refreshGradeAutomatically) {
        refreshCurrentGrade();
      }
    })();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("성적/학점 조회"),
      body: _progress == GradeProgress.init
          ? Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    LinearProgressIndicator(),
                    SizedBox(
                      width: 1,
                      height: 15,
                    ),
                    Text("전체 학기 성적을 불러오고 있습니다..."),
                  ],
                ),
              ),
            )
          : SmartRefresher(
              controller: _refreshController,
              onRefresh: refreshCurrentGradeWithPull,
              // onLoading: refreshCurrentGradeWithPull,
              child: ListView(
                controller: ScrollController(),
                children: [
                  SingleChildScrollView(
                    child: Screenshot(
                      controller: _imageController,
                      child: Container(
                        color: globals.isLightMode ? (_progress == GradeProgress.init ? null : const Color.fromRGBO(241, 242, 245, 1)) : null,
                        child: ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: <Widget>[
                                GradePageHeader(_semesterSubjects, callbackSelectSubject, refreshCurrentGrade, _exportImage, _showRanking),
                              ] +
                              _semesterSubjects.subjects.map((e) => SubjectWidget(e, _exportImage, _showSubjectInfo)).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
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
                            padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
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
                                            await ImageGallerySaver.saveImage(bytes!,
                                                name:
                                                    "${_semesterSubjects.currentSemester.year}-${_semesterSubjects.currentSemester.semester.name}-${DateTime.now().toLocal().millisecondsSinceEpoch}");

                                            setState(() {
                                              _exportImage = false;
                                            });

                                            showToast("이미지를 저장했습니다.");
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
