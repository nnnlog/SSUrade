import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ssurade_application/ssurade_application.dart';
import 'package:ssurade_bloc/ssurade_bloc.dart';

class GradePageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<GradeBloc, GradeState>(builder: (context, state) {
                  if (state is! GradeShowing) return Container();
                  return DropdownButton(
                    icon: Visibility(
                      visible: context.select((GradeBloc bloc) => bloc.state is GradeShowing && !(bloc.state as GradeShowing).isExporting),
                      child: const Icon(Icons.arrow_drop_down),
                    ),
                    items: state.semesterSubjectsManager.data.entries
                        .map(
                          (e) => DropdownMenuItem<YearSemester>(
                            value: e.key,
                            child: Text(
                              "${e.key.year}학년도 ${e.key.semester.displayText} (${e.value.totalCredit}학점)",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Pretendard",
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value is YearSemester) {
                        context.read<GradeBloc>().add(GradeYearSemesterSelected(value));
                      }
                    },
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                      fontFamily: "Pretendard",
                    ),
                    underline: Container(),
                    value: state.showingSemester,
                    isDense: true,
                  );
                }),
                TextButton(
                  onPressed: context.read<GradeBloc>().state is GradeShowing
                      ? () {
                          context.read<GradeBloc>().add(GradeInformationRefreshRequested((context.read<GradeBloc>().state as GradeShowing).showingSemester));
                        }
                      : null,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(30, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  child: Visibility(
                    visible: context.select((GradeBloc bloc) => bloc.state is GradeShowing && !(bloc.state as GradeShowing).isExporting),
                    child: Icon(
                      Icons.refresh,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "나의 평균 학점",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.6),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        BlocSelector<GradeBloc, GradeState, String>(selector: (state) {
                          if (state is! GradeShowing) return "";
                          return state.semesterSubjectsManager.data[state.showingSemester]?.averageGrade.toStringAsFixed(2) ?? "";
                        }, builder: (context, value) {
                          return Text(
                            value,
                            style: const TextStyle(
                              fontSize: 50,
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
                            fontSize: 20,
                            color: Colors.black.withOpacity(0.5),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                BlocBuilder<GradeBloc, GradeState>(builder: (context, state) {
                  if (state is! GradeShowing) return Container();
                  return Visibility(
                    visible: !state.isExporting || state.isDisplayRankingDuringExporting,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "학기 석차",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.6),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          "${state.semesterSubjectsManager.data[state.showingSemester]?.semesterRanking.display ?? ''} ${state.semesterSubjectsManager.data[state.showingSemester]?.semesterRanking.isEmpty ?? true ? '' : '(상위 ${state.semesterSubjectsManager.data[state.showingSemester]?.semesterRanking.percentage.toStringAsFixed(1)}%)'}",
                          // "${widget.data.semesterRanking.display} ${widget.data.semesterRanking.isEmpty ? '' : '(상위 ${widget.data.semesterRanking.percentage.toStringAsFixed(1)}%)'}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          "전체 석차",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.6),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          "${state.semesterSubjectsManager.data[state.showingSemester]?.totalRanking.display ?? ''} ${state.semesterSubjectsManager.data[state.showingSemester]?.totalRanking.isEmpty ?? true ? '' : '(상위 ${state.semesterSubjectsManager.data[state.showingSemester]?.totalRanking.percentage.toStringAsFixed(1)}%)'}",
                          // "${widget.data.totalRanking.display} ${widget.data.totalRanking.isEmpty ? '' : '(상위 ${widget.data.totalRanking.percentage.toStringAsFixed(1)}%)'}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
}
