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

  @override
  void initState() {
    super.initState();

    var time = DateTime.now();
    if (time.month <= 2) {
      search = YearSemester((time.year - 1).toString(), Semester.second);
    } else if (time.month <= 8) {
      search = YearSemester(time.year.toString(), Semester.first);
    } else {
      search = YearSemester(time.year.toString(), Semester.second);
    }

    (() async {
      var res = await globals.setting.saintSession.getGrade(search);
      if (res == null) {
        if (mounted) {
          Navigator.pop(context);
        }
        showToast("성적 정보를 가져오지 못했습니다.\n다시 시도해주세요.");
        return;
      }

      setState(() {
        _subjects = res;
        _progress = GradeProgress.finish;
      });
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
                    Text("정보를 불러오고 있습니다...")
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${search.year}학년도 ${search.semester.name}",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
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
