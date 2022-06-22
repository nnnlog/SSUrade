import 'package:flutter/material.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/Progress.dart';
import 'package:ssurade/types/SubjectData.dart';
import 'package:ssurade/utils/toast.dart';

class GradePage extends StatefulWidget {
  const GradePage({super.key});

  @override
  State<StatefulWidget> createState() => _GradePageState();
}

class _GradePageState extends State<GradePage> {
  GradeProgress _progress = GradeProgress.init;
  late SubjectDataList _subjects;

  @override
  void initState() {
    super.initState();

    (() async {
      var res = await globals.setting.saintSession.fetchGrade();
      if (res == null) {
        showToast("성적 정보를 가져오지 못했습니다.");
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
          : Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  height: 200,
                  width: 1000,
                  child: Column(
                    children: [
                      const Text("2022학년도 1학기"),
                      const Text("나의 평균 학점"),
                      Text("${_subjects.averageGrade} / 4.5"),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
