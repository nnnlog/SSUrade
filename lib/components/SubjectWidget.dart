import 'package:flutter/material.dart';
import 'package:ssurade/components/GradeLogo.dart';
import 'package:ssurade/types/SubjectData.dart';

class SubjectWidget extends StatefulWidget {
  SubjectData _subjectData;

  SubjectWidget(this._subjectData, {super.key});

  @override
  State<StatefulWidget> createState() => _SubjectWidgetState(_subjectData);
}

class _SubjectWidgetState extends State<SubjectWidget> {
  final SubjectData _subjectData;

  _SubjectWidgetState(this._subjectData);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: IntrinsicHeight(
        child: Container(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GradeLogo.parse(_subjectData.grade),
                Container(
                  width: 13,
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _subjectData.name,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                        softWrap: true,
                      ),
                      Container(
                        height: 4,
                      ),
                      Text(
                        "${_subjectData.professor} · ${_subjectData.credit.toStringAsPrecision(1)}학점",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
