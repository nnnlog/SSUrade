import 'dart:collection';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ssurade/components/common/custom_app_bar.dart';
import 'package:ssurade_application/ssurade_application.dart';
import 'package:ssurade_bloc/ssurade_bloc.dart';

class GradeStatisticsByCategoryPage extends StatefulWidget {
  const GradeStatisticsByCategoryPage({super.key});

  @override
  State<StatefulWidget> createState() => _GradeStatisticsByCategoryPageState();
}

class _GradeStatisticsByCategoryPageState extends State<GradeStatisticsByCategoryPage> with SingleTickerProviderStateMixin {
  final _key1 = "전체", _key2 = "전공";
  late TabController _controller;

  Map<String, List<(Subject, YearSemester)>> getCategoryCredits(SemesterSubjectsManager manager) {
    Map<String, List<(Subject, YearSemester)>> ret = {};
    for (var value in manager.data.values) {
      for (var subject in value.subjects.values) {
        if (!subject.excluded) {
          if (!ret.containsKey(subject.category)) ret[subject.category] = [];
          if (!ret.containsKey(_key1)) ret[_key1] = [];
          ret[subject.category]!.add((subject, value.currentSemester));
          ret[_key1]!.add((subject, value.currentSemester));
          if (subject.isMajor) {
            if (!ret.containsKey(_key2)) ret[_key2] = [];
            ret[_key2]!.add((subject, value.currentSemester));
          }
        }
      }
    }

    for (var value in ret.values) {
      value.sort((a, b) {
        var ret = a.$2.compareTo(b.$2);
        if (ret == 0) ret = a.$1.name.compareTo(b.$1.name);
        return ret;
      });
    }

    return ret;
  }

  @override
  void initState() {
    super.initState();

    // data = getCategoryCredits();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GradeInquiryBloc(subjectViewModelUseCase: context.read<SubjectViewModelUseCase>()),
      child: BlocBuilder<GradeInquiryBloc, GradeInquiryState>(builder: (context, state) {
        return switch (state) {
          GradeInquiryInitial() => run(() {
              context.read<GradeInquiryBloc>().add(GradeInquiryReady());
              return Container();
            }),
          GradeInquiryEmpty() => run(() {
              Navigator.pop(context);
              return Container();
            }),
          GradeInquiryShowing() => run(() {
              var data = getCategoryCredits(state.semesterSubjectsManager);
              _controller = TabController(length: data.keys.length, vsync: this);
              return Scaffold(
                  appBar: customAppBar("이수 구분별 성적 통계",
                      bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(50),
                          child: TabBar(
                            tabs: (data.keys.toList()
                                  ..remove(_key1)
                                  ..sort((a, b) => a.compareTo(b))
                                  ..insert(0, _key1))
                                .map(
                                  (e) => SizedBox(
                                    height: 50,
                                    child: Center(
                                      child: Text(
                                        e,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            isScrollable: true,
                            controller: _controller,
                          ))),
                  body: TabBarView(
                    controller: _controller,
                    children: (data.keys.toList()
                          ..remove(_key1)
                          ..sort((a, b) => a.compareTo(b))
                          ..insert(0, _key1)) // key1이 먼저 오도록 강제함
                        .map(
                          (key) => SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const NeverScrollableScrollPhysics(),
                                child: Column(
                                  children: [
                                    DataTable(
                                      columnSpacing: 0,
                                      horizontalMargin: 0,
                                      headingRowHeight: 0,
                                      showBottomBorder: true,
                                      columns: [DataColumn(label: Container()), DataColumn(label: Container())],
                                      rows: [
                                        ("이수 과목 수", data[key]!.map((e) => e.$1.excluded ? 0 : 1).reduce((value, element) => value + element).toString()),
                                        ("이수 학점 수", data[key]!.map((e) => e.$1.excluded ? 0 : e.$1.credit).reduce((value, element) => value + element).toString()),
                                        ("P/F 제외 이수 학점 수", data[key]!.map((e) => e.$1.excluded || e.$1.isPassFail ? 0 : e.$1.credit).reduce((value, element) => value + element).toString()),
                                        (
                                          "평점",
                                          SemesterSubjects(
                                            subjects: SplayTreeMap.fromIterable(
                                              ([...data[key]!]..removeWhere((element) => element.$1.excluded)),
                                              key: (e) => e.hashCode.toString(),
                                              value: (e) => e.$1,
                                            ),
                                            totalRanking: Ranking.unknown,
                                            semesterRanking: Ranking.unknown,
                                            currentSemester: YearSemester(year: 0, semester: Semester.first),
                                          ).averageGrade.toStringAsFixed(2),
                                        ),
                                      ]
                                          .map((e) => DataRow(cells: [
                                                DataCell(
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width * 0.5,
                                                    child: Text(
                                                      e.$1,
                                                      textAlign: TextAlign.center,
                                                      softWrap: true,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width * 0.5,
                                                    child: Text(
                                                      e.$2,
                                                      textAlign: TextAlign.center,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                ),
                                              ]))
                                          .toList(),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    DataTable(
                                      columnSpacing: 0,
                                      horizontalMargin: 0,
                                      headingTextStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      columns: ["이수 학기", "과목명", "학점", "성적"]
                                          .map(
                                            (e) => DataColumn(
                                              label: Expanded(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      e,
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      rows: data[key]!
                                          .map((e) => DataRow(
                                                onLongPress: e.$1.excluded
                                                    ? () {
                                                        // showToast("졸업 사정에서 제외된 수강 기록이에요.");
                                                      }
                                                    : null,
                                                cells: [
                                                  DataCell(
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.25,
                                                      child: Text(
                                                        "${e.$2.year}-${e.$2.semester.displayText.replaceAll("학기", "")}",
                                                        textAlign: TextAlign.center,
                                                        softWrap: true,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.45,
                                                      child: Text(
                                                        // Need dynamic height, but DataTable doesn't support.
                                                        e.$1.name,
                                                        textAlign: TextAlign.center,
                                                        softWrap: true,
                                                        style: TextStyle(decoration: e.$1.excluded ? TextDecoration.lineThrough : TextDecoration.none),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.15,
                                                      child: Text(
                                                        e.$1.credit.toStringAsFixed(1),
                                                        textAlign: TextAlign.center,
                                                        softWrap: true,
                                                        style: TextStyle(decoration: e.$1.excluded ? TextDecoration.lineThrough : TextDecoration.none),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.15,
                                                      child: Text(
                                                        e.$1.grade,
                                                        textAlign: TextAlign.center,
                                                        softWrap: true,
                                                        style: TextStyle(decoration: e.$1.excluded ? TextDecoration.lineThrough : TextDecoration.none),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                )),
                          ),
                        )
                        .toList(),
                  ));
            }),
        };
      }),
    );
  }
}
