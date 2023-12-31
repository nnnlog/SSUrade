import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:ssurade/components/CustomAppBar.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/semester/YearSemester.dart';
import 'package:ssurade/types/subject/SemesterSubjects.dart';
import 'package:ssurade/types/subject/Subject.dart';
import 'package:tuple/tuple.dart';

class GradeStatisticsPage extends StatefulWidget {
  const GradeStatisticsPage({super.key});

  @override
  State<StatefulWidget> createState() => _GradeStatisticsPageState();
}

class _GradeStatisticsPageState extends State<GradeStatisticsPage> {
  late SemesterSubjects subjects;
  Map<YearSemester, ExpansionTileController> controllers = {};

  @override
  void initState() {
    super.initState();

    List<Subject> subjects = [];
    for (var key in globals.semesterSubjectsManager.data.keys) {
      controllers[key] = ExpansionTileController();
    }
    for (var value in globals.semesterSubjectsManager.data.values) {
      for (var subject in value.subjects.values) {
        if (subject.isExcluded) continue;
        subjects.add(subject);
      }
    }

    this.subjects = SemesterSubjects(SplayTreeMap.fromIterable(subjects, key: (e) => e.hashCode.toString()));
  }

  @override
  Widget build(BuildContext context) {
    var data = globals.semesterSubjectsManager.data;

    return Scaffold(
      appBar: customAppBar("성적 통계"),
      backgroundColor: const Color.fromRGBO(241, 242, 245, 1),
      body: ListView(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              color: globals.isLightMode ? Colors.white : Colors.black.withOpacity(0.45),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 3,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      const Flexible(
                        fit: FlexFit.tight,
                        child: Text(
                          "전체 평점",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              subjects.averageGrade.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Text(
                              "/ 4.50",
                              style: TextStyle(
                                fontSize: 16,
                                color: globals.isLightMode ? Colors.black.withOpacity(0.5) : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      const Flexible(
                        fit: FlexFit.tight,
                        child: Text(
                          "전공 평점",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              subjects.averageMajorGrade.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Text(
                              "/ 4.50",
                              style: TextStyle(
                                fontSize: 13,
                                color: globals.isLightMode ? Colors.black.withOpacity(0.5) : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      const Flexible(
                        fit: FlexFit.tight,
                        child: Text(
                          "이수 학점",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              subjects.totalCredit.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ...data.keys.map(
                  (e) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ],
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: ExpansionTile(
                      controller: controllers[e]!,
                      shape: Border.all(width: 0, color: Colors.transparent),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "  ${e.year}학년도 ${e.semester.displayName}",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                data[e]!.averageGrade.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Text(
                                " / 4.50",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(40, 10, 40, 20),
                      children: [
                        Column(
                          children: [
                            Tuple2("이수 학점", data[e]!.totalCredit.toStringAsFixed(1)),
                            Tuple2("이수 전공 학점", data[e]!.majorCredit.toStringAsFixed(1)),
                            Tuple2("전공 평점", data[e]!.averageMajorGrade.toStringAsFixed(2)),
                            Tuple2("학기 석차", data[e]!.semesterRanking.display),
                            Tuple2("전체 석차", data[e]!.totalRanking.display),
                          ]
                              .map((e) => Container(
                                    margin: const EdgeInsets.symmetric(vertical: 3),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          e.item1,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(color: Colors.black54),
                                        ),
                                        Expanded(child: Container()),
                                        Text(
                                          e.item2,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        for (var controller in controllers.values) {
                          controller.expand();
                        }
                      },
                      child: const Text("전체 펼치기"),
                    ),
                    TextButton(
                      onPressed: () {
                        for (var controller in controllers.values) {
                          controller.collapse();
                        }
                      },
                      child: const Text("전체 접기"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
