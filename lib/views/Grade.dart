import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ssurade/components/CustomAppBar.dart';
import 'package:ssurade/components/GradeHeader.dart';
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
  late YearSemester _search;
  late SubjectDataList _subjects;
  final RefreshController _refreshController = RefreshController();

  GradeProgress _progress = GradeProgress.init;
  bool _lockedForRefresh = false;

  void callbackSelectSubject(YearSemester value) {
    setState(() {
      _search = value;
      _subjects = globals.subjectDataCache.data[_search]!;
    });
  }

  Future<void> refreshCurrentGrade() async {
    if (_lockedForRefresh) return;
    _lockedForRefresh = true;

    showToast("${_search.year}학년도 ${_search.semester.name} 성적을 불러옵니다.");
    var tmp = _search;

    SubjectDataList? data = (await globals.setting.uSaintSession.getGrade(_search));
    if (!mounted) return;
    if (data == null) {
      showToast("${_search.year}학년도 ${_search.semester.name} 성적을 불러오지 못했습니다.");
      return;
    }

    globals.subjectDataCache.data[_search] = data;
    globals.subjectDataCache.saveFile();

    if (tmp != _search) {
      return;
    }
    setState(() {
      _subjects = data;
    });

    showToast("${_search.year}학년도 ${_search.semester.name} 성적을 불러왔습니다.");
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
      if (globals.subjectDataCache.isEmpty) {
        needRefresh = false;

        var res = await globals.setting.uSaintSession.getAllGrade();
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

      _search = YearSemester(-1, Semester.first);
      globals.subjectDataCache.data.forEach((key, value) {
        if (_search < key) {
          _search = key;
        }
      });

      if (_search.year == -1) {
        if (mounted) {
          Navigator.pop(context);
        }
        showToast("성적 정보가 없습니다.");
        return;
      }

      setState(() {
        _subjects = globals.subjectDataCache.data[_search]!;
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
      backgroundColor: globals.isLightMode ? (_progress == GradeProgress.init ? null : const Color.fromRGBO(241, 242, 245, 1)) : null,
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
                children: [
                  GradeSemesterHeader(_search, _subjects, callbackSelectSubject, refreshCurrentGrade),
                  Column(
                    children: _subjects.subjectDataList.map((e) => SubjectWidget(e)).toList(),
                  ),
                ],
              ),
            ),
    );
  }
}
