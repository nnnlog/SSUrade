import 'package:flutter/material.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/Semester.dart';
import 'package:ssurade/types/SubjectData.dart';

class GradeSemesterHeader extends StatefulWidget {
  final YearSemester currentSemester;
  final SubjectDataList currentSubjects;
  final Function(YearSemester) callbackSelectSubject;
  final void Function() refreshCurrentGrade;

  const GradeSemesterHeader(this.currentSemester, this.currentSubjects, this.callbackSelectSubject, this.refreshCurrentGrade, {super.key});

  @override
  State<StatefulWidget> createState() => _GradeSemesterHeaderState();
}

class _GradeSemesterHeaderState extends State<GradeSemesterHeader> {
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
                  value: widget.currentSemester,
                  isDense: true,
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "나의 평균 학점",
                  style: TextStyle(
                    fontSize: 16,
                    color: globals.isLightMode ? Colors.black.withOpacity(0.6) : Colors.white,
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
                      widget.currentSubjects.averageGrade.toStringAsPrecision(3),
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
                  onPressed: widget.refreshCurrentGrade,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(30, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    primary: Colors.black.withOpacity(0.7),
                  ),
                  child: Icon(
                    Icons.refresh,
                    color: globals.isLightMode ? Colors.black : Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
