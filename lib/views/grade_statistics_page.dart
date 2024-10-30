import 'dart:collection';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ssurade/components/common/custom_app_bar.dart';
import 'package:ssurade_application/ssurade_application.dart';
import 'package:ssurade_bloc/ssurade_bloc.dart';

class GradeStatisticsPage extends StatefulWidget {
  const GradeStatisticsPage({super.key});

  @override
  State<StatefulWidget> createState() => _GradeStatisticsPageState();
}

class _GradeStatisticsPageState extends State<GradeStatisticsPage> {
  Map<YearSemester, ExpansionTileController> _controllers = {};

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GradeInquiryBloc(subjectViewModelUseCase: context.read<SubjectViewModelUseCase>()),
      child: Scaffold(
        appBar: customAppBar("성적 통계"),
        backgroundColor: const Color.fromRGBO(241, 242, 245, 1),
        body: BlocBuilder<GradeInquiryBloc, GradeInquiryState>(builder: (context, state) {
          return switch (state) {
            GradeInquiryInitial() => run(() {
                context.read<GradeInquiryBloc>().add(GradeInquiryReady());
                return Container();
              }),
            GradeInquiryEmpty() => run(() {
                Navigator.pop(context);
                return Container();
              }),
            GradeInquiryShowing() => ListView(
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
                                    BlocSelector<GradeInquiryBloc, GradeInquiryState, String>(selector: (state) {
                                      if (state is GradeInquiryShowing) {
                                        return state.semesterSubjectsManager.data.values
                                            .map((semesterSubjects) => semesterSubjects.subjects.values.toList())
                                            .expand((i) => i)
                                            .let((it) {
                                              return SemesterSubjects(
                                                  subjects: SplayTreeMap.fromIterable(it, key: (subject) => subject.code),
                                                  semesterRanking: Ranking.unknown,
                                                  totalRanking: Ranking.unknown,
                                                  currentSemester: YearSemester(
                                                    year: 0,
                                                    semester: Semester.first,
                                                  ));
                                            })
                                            .averageGrade
                                            .toStringAsFixed(2);
                                      }
                                      return "";
                                    }, builder: (context, state) {
                                      return Text(
                                        state,
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      );
                                    }),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                    Text(
                                      "/ 4.50",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black.withOpacity(0.5),
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
                                    BlocSelector<GradeInquiryBloc, GradeInquiryState, String>(selector: (state) {
                                      if (state is GradeInquiryShowing) {
                                        return state.semesterSubjectsManager.data.values
                                            .map((semesterSubjects) => semesterSubjects.subjects.values.toList())
                                            .expand((i) => i)
                                            .let((it) {
                                              return SemesterSubjects(
                                                  subjects: SplayTreeMap.fromIterable(it, key: (subject) => subject.code),
                                                  semesterRanking: Ranking.unknown,
                                                  totalRanking: Ranking.unknown,
                                                  currentSemester: YearSemester(
                                                    year: 0,
                                                    semester: Semester.first,
                                                  ));
                                            })
                                            .averageMajorGrade
                                            .toStringAsFixed(2);
                                      }
                                      return "";
                                    }, builder: (context, state) {
                                      return Text(
                                        state,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      );
                                    }),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                    Text(
                                      "/ 4.50",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black.withOpacity(0.5),
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
                                    BlocSelector<GradeInquiryBloc, GradeInquiryState, String>(selector: (state) {
                                      if (state is GradeInquiryShowing) {
                                        return state.semesterSubjectsManager.data.values
                                            .map((semesterSubjects) => semesterSubjects.subjects.values.toList())
                                            .expand((i) => i)
                                            .let((it) {
                                              return SemesterSubjects(
                                                  subjects: SplayTreeMap.fromIterable(it, key: (subject) => subject.code),
                                                  semesterRanking: Ranking.unknown,
                                                  totalRanking: Ranking.unknown,
                                                  currentSemester: YearSemester(
                                                    year: 0,
                                                    semester: Semester.first,
                                                  ));
                                            })
                                            .totalCredit
                                            .toStringAsFixed(1);
                                      }
                                      return "";
                                    }, builder: (context, state) {
                                      return Text(
                                        state,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      );
                                    }),
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
                        BlocSelector<GradeInquiryBloc, GradeInquiryState, SplayTreeMap<YearSemester, SemesterSubjects>>(selector: (state) {
                          if (state is GradeInquiryShowing) {
                            return state.semesterSubjectsManager.data;
                          }
                          return SplayTreeMap();
                        }, builder: (context, data) {
                          return Column(
                              children: data.keys
                                  .map(
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
                                        controller: _controllers[e] ??= ExpansionTileController(),
                                        shape: Border.all(width: 0, color: Colors.transparent),
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "  ${e.year}학년도 ${e.semester.displayText}",
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
                                              ("이수 학점", data[e]!.totalCredit.toStringAsFixed(1)),
                                              ("이수 전공 학점", data[e]!.majorCredit.toStringAsFixed(1)),
                                              ("전공 평점", data[e]!.averageMajorGrade.toStringAsFixed(2)),
                                              ("학기 석차", data[e]!.semesterRanking.display),
                                              ("전체 석차", data[e]!.totalRanking.display),
                                            ]
                                                .map((e) => Container(
                                                      margin: const EdgeInsets.symmetric(vertical: 3),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            e.$1,
                                                            textAlign: TextAlign.left,
                                                            style: const TextStyle(color: Colors.black54),
                                                          ),
                                                          Expanded(child: Container()),
                                                          Text(
                                                            e.$2,
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
                                  )
                                  .toList());
                        }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                              onPressed: () {
                                for (var controller in _controllers.values) {
                                  controller.expand();
                                }
                              },
                              child: const Text("전체 펼치기"),
                            ),
                            TextButton(
                              onPressed: () {
                                for (var controller in _controllers.values) {
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
          };
        }),
      ),
    );
  }
}
