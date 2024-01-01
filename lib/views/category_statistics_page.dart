import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:ssurade/components/custom_app_bar.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/semester/year_semester.dart';
import 'package:ssurade/types/subject/semester_subjects.dart';
import 'package:ssurade/types/subject/subject.dart';
import 'package:ssurade/utils/toast.dart';
import 'package:tuple/tuple.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatefulWidget> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with SingleTickerProviderStateMixin {
  var key1 = "전체", key2 = "전공";
  late Map<String, List<Tuple2<Subject, YearSemester>>> data;
  late TabController _controller;

  Map<String, List<Tuple2<Subject, YearSemester>>> getCategoryCredits() {
    Map<String, List<Tuple2<Subject, YearSemester>>> ret = {};
    for (var value in globals.semesterSubjectsManager.data.values) {
      for (var subject in value.subjects.values) {
        if (!subject.isExcluded) {
          if (!ret.containsKey(subject.category)) ret[subject.category] = [];
          if (!ret.containsKey(key1)) ret[key1] = [];
          ret[subject.category]!.add(Tuple2(subject, value.currentSemester));
          ret[key1]!.add(Tuple2(subject, value.currentSemester));
          if (subject.isMajor) {
            if (!ret.containsKey(key2)) ret[key2] = [];
            ret[key2]!.add(Tuple2(subject, value.currentSemester));
          }
        }
      }
    }

    for (var value in ret.values) {
      value.sort((a, b) {
        var ret = a.item2.compareTo(b.item2);
        if (ret == 0) ret = a.item1.name.compareTo(b.item1.name);
        return ret;
      });
    }

    return ret;
  }

  @override
  void initState() {
    super.initState();

    data = getCategoryCredits();
    _controller = TabController(length: data.keys.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      showToast("성적 정보가 없어요. 성적 정보를 불러온 후 다시 시도해주세요.");
      Navigator.pop(context);
      return Container();
    }

    return Scaffold(
      appBar: customAppBar("이수 구분별 성적 통계",
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: TabBar(
                tabs: (data.keys.toList()
                      ..remove(key1)
                      ..sort((a, b) => a.compareTo(b))
                      ..insert(0, key1))
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
              ..remove(key1)
              ..sort((a, b) => a.compareTo(b))
              ..insert(0, key1))
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
                            Tuple2("이수 과목 수", data[key]!.map((e) => e.item1.isExcluded ? 0 : 1).reduce((value, element) => value + element).toString()),
                            Tuple2("이수 학점 수", data[key]!.map((e) => e.item1.isExcluded ? 0 : e.item1.credit).reduce((value, element) => value + element).toString()),
                            Tuple2("P/F 제외 이수 학점 수", data[key]!.map((e) => e.item1.isExcluded || e.item1.isPassFail ? 0 : e.item1.credit).reduce((value, element) => value + element).toString()),
                            Tuple2(
                              "평점",
                              SemesterSubjects(SplayTreeMap.fromIterable(
                                ([...data[key]!]..removeWhere((element) => element.item1.isExcluded)),
                                key: (e) => e.hashCode.toString(),
                                value: (e) => e.item1,
                              )).averageGrade.toStringAsFixed(2),
                            ),
                          ]
                              .map((e) => DataRow(cells: [
                                    DataCell(
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.5,
                                        child: Text(
                                          e.item1,
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
                                          e.item2,
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
                                    onLongPress: e.item1.isExcluded
                                        ? () {
                                            showToast("졸업 사정에서 제외된 수강 기록이에요.");
                                          }
                                        : null,
                                    cells: [
                                      DataCell(
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.25,
                                          child: Text(
                                            "${e.item2.year}-${e.item2.semester.displayName.replaceAll("학기", "")}",
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
                                            e.item1.name,
                                            textAlign: TextAlign.center,
                                            softWrap: true,
                                            style: TextStyle(decoration: e.item1.isExcluded ? TextDecoration.lineThrough : TextDecoration.none),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.15,
                                          child: Text(
                                            e.item1.credit.toStringAsFixed(1),
                                            textAlign: TextAlign.center,
                                            softWrap: true,
                                            style: TextStyle(decoration: e.item1.isExcluded ? TextDecoration.lineThrough : TextDecoration.none),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.15,
                                          child: Text(
                                            e.item1.grade,
                                            textAlign: TextAlign.center,
                                            softWrap: true,
                                            style: TextStyle(decoration: e.item1.isExcluded ? TextDecoration.lineThrough : TextDecoration.none),
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
      ),
    );
  }
}
