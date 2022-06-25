import 'package:flutter/material.dart';
import 'package:ssurade/components/SubjectWidget.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/Progress.dart';
import 'package:ssurade/types/Semester.dart';
import 'package:ssurade/types/SubjectData.dart';
import 'package:ssurade/utils/toast.dart';

class GradePage extends StatefulWidget {
  const GradePage({super.key});

  @override
  State<StatefulWidget> createState() => _GradePageState();
}

class _GradePageState extends State<GradePage> {
  late YearSemester search;
  GradeProgress _progress = GradeProgress.init;
  late SubjectDataList _subjects;
  bool _lockedForRefresh = false;

  Future<void> refreshCurrentGrade() async {
    if (_lockedForRefresh) return;
    _lockedForRefresh = true;

    showToast("${search.year}학년도 ${search.semester.name} 성적 동기화를 시작합니다.");

    SubjectDataList data = (await globals.setting.saintSession.getGrade(search))!;
    setState(() {
      _subjects = data;
    });
    globals.subjectDataCache.data[search] = data;
    globals.subjectDataCache.saveFile();

    showToast("${search.year}학년도 ${search.semester.name} 성적을 불러왔습니다.");
    _lockedForRefresh = false;
  }

  @override
  void initState() {
    super.initState();

    (() async {
      bool needRefresh = true;
      if (globals.subjectDataCache.isEmpty) {
        needRefresh = false;

        var res = await globals.setting.saintSession.getAllGrade();
        if (res == null) {
          if (mounted) {
            Navigator.pop(context);
          }
          showToast("성적 정보를 가져오지 못했습니다.\n다시 시도해주세요.");
          return;
        }

        globals.subjectDataCache.data = res;
        globals.subjectDataCache.saveFile();
      }

      search = YearSemester(-1, Semester.first);
      globals.subjectDataCache.data.forEach((key, value) {
        if (search < key) {
          search = key;
        }
      });

      if (search.year == -1) {
        if (mounted) {
          Navigator.pop(context);
        }
        showToast("성적 정보가 없습니다.");
        return;
      }

      setState(() {
        _subjects = globals.subjectDataCache.data[search]!;
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
      appBar: AppBar(
        title: const Text("성적/학점 조회", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        shadowColor: const Color.fromRGBO(0, 0, 0, 0),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: _progress == GradeProgress.init ? null : const Color.fromRGBO(241, 242, 245, 1),
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
                    Text("정보를 불러오고 있습니다..."),
                  ],
                ),
              ),
            )
          : ListView(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  width: 1000,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButton(
                              items: globals.subjectDataCache.data.entries
                                  .map((e) => DropdownMenuItem<YearSemester>(value: e.key, child: Text("${e.key.year}학년도 ${e.key.semester.name}")))
                                  .toList(),
                              onChanged: (value) {
                                if (value is YearSemester) {
                                  setState(() {
                                    search = value;
                                    _subjects = globals.subjectDataCache.data[search]!;
                                  });
                                }
                              },
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.black.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                              underline: Container(),
                              value: search,
                              isDense: true,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              "나의 평균 학점",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black.withOpacity(0.6),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _subjects.averageGrade.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                Text(
                                  "/ 4.50",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black.withOpacity(0.5),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextButton(
                              onPressed: refreshCurrentGrade,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(30, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                primary: Colors.black.withOpacity(0.7),
                              ),
                              child: const Icon(
                                Icons.refresh,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: _subjects.subjectData.map((e) => SubjectWidget(e)).toList(),
                ),
              ],
            ),
    );
  }
}
