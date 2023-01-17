import 'package:flutter/material.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/Semester.dart';
import 'package:ssurade/types/YearSemester.dart';
import 'package:ssurade/types/subject/SemesterSubjects.dart';
import 'package:ssurade/utils/DoubleToString.dart';

class GradePageHeader extends StatefulWidget {
  final SemesterSubjects data;
  final Function(YearSemester) callbackSelectSubject;
  final void Function() refreshCurrentGrade;
  final bool _exportImage, _showRanking;

  const GradePageHeader(this.data, this.callbackSelectSubject, this.refreshCurrentGrade, this._exportImage, this._showRanking, {super.key});

  @override
  State<StatefulWidget> createState() => _GradePageHeaderState();
}

class _GradePageHeaderState extends State<GradePageHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton(
                  icon: Visibility(
                    visible: !widget._exportImage,
                    child: const Icon(Icons.arrow_drop_down),
                  ),
                  items: globals.semesterSubjectsManager.data.entries
                      .map((e) => DropdownMenuItem<YearSemester>(
                            value: e.key,
                            child: Text(
                              "${e.key.year}학년도 ${e.key.semester.name} (${e.value.totalCredit}학점)",
                              style: TextStyle(
                                color: globals.isLightMode ? Colors.black : Colors.white,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value is YearSemester) {
                      widget.callbackSelectSubject(value);
                    }
                  },
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                  underline: Container(),
                  value: widget.data.currentSemester,
                  isDense: true,
                ),
                TextButton(
                  onPressed: widget.refreshCurrentGrade,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(30, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    primary: Colors.black.withOpacity(0.7),
                  ),
                  child: Visibility(
                    visible: !widget._exportImage,
                    child: Icon(
                      Icons.refresh,
                      color: globals.isLightMode ? Colors.black : Colors.white,
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
                        color: globals.isLightMode ? Colors.black.withOpacity(0.6) : Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          toStringWithPrecision(widget.data.averageGrade, 2),
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
                            color: globals.isLightMode ? Colors.black.withOpacity(0.5) : Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Visibility(
                  visible: !widget._exportImage || widget._showRanking,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "학기 석차",
                        style: TextStyle(
                          fontSize: 14,
                          color: globals.isLightMode ? Colors.black.withOpacity(0.6) : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        "${widget.data.semesterRanking.toString()} ${widget.data.semesterRanking.isEmpty ? '' : '(상위 ${toStringWithPrecision(widget.data.semesterRanking.percentage, 1)}%)'}",
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
                          color: globals.isLightMode ? Colors.black.withOpacity(0.6) : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        "${widget.data.totalRanking.toString()} ${widget.data.totalRanking.isEmpty ? '' : '(상위 ${toStringWithPrecision(widget.data.totalRanking.percentage, 1)}%)'}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
          ],
        ),
      ),
    );
  }
}
