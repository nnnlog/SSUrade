import 'package:flutter/material.dart';
import 'package:ssurade/components/grade/grade_logo.dart';
import 'package:ssurade_application/ssurade_application.dart';

class SubjectWidget extends StatefulWidget {
  final Subject _subjectData;
  final bool _exportImage, _showSubject;

  const SubjectWidget(this._subjectData, this._exportImage, this._showSubject, {super.key});

  @override
  State<StatefulWidget> createState() => _SubjectWidgetState();
}

class _SubjectWidgetState extends State<SubjectWidget> {
  final Map<Subject, ExpansionTileController> _expansionTileController = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
        child: ExpansionTile(
          iconColor: widget._exportImage ? Colors.transparent : null,
          collapsedIconColor: widget._exportImage ? Colors.transparent : null,
          controller: _expansionTileController[widget._subjectData] ??= ExpansionTileController(),
          tilePadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 40),
          shape: Border.all(width: 0, color: Colors.transparent),
          title: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GradeLogo.parse(widget._subjectData.grade),
                Container(
                  width: 13,
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (!widget._exportImage || widget._showSubject) ? widget._subjectData.name : "",
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: Colors.black,
                        ),
                        softWrap: true,
                      ),
                      Text(
                        "${widget._subjectData.professor.isNotEmpty && (!widget._exportImage || widget._showSubject) ? "${widget._subjectData.professor} · " : ""}${widget._subjectData.credit.toStringAsPrecision(1)}학점",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.4),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          children: [
            {
              "이수 구분": widget._subjectData.category,
              "성적 산출 방식": widget._subjectData.isPassFail || widget._subjectData.grade == "P" ? "P/F" : "100점 기준",
              "최종 성적": widget._subjectData.score,
              "성적 기호": widget._subjectData.grade,
            },
            widget._subjectData.detail.isEmpty ? {"-": "성적 상세 정보가 없어요. 현재 학기 정보를 다시 불러오세요."} : widget._subjectData.detail
          ]
              .map((e) => Column(
                    children: [
                      ...e.entries.map<Row>((entry) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Flexible(
                                child: SelectableText(
                                  entry.key,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(color: Colors.black54),
                                  strutStyle: const StrutStyle(height: 0, forceStrutHeight: true),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: SelectableText(
                                  entry.value,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(height: 20),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }
}
