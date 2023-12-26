import 'package:flutter/material.dart';
import 'package:ssurade/components/GradeLogo.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/subject/Subject.dart';
import 'package:ssurade/utils/toast.dart';

class SubjectWidget extends StatefulWidget {
  final Subject _subjectData;
  final bool _exportImage, _showSubject;

  const SubjectWidget(this._subjectData, this._exportImage, this._showSubject, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SubjectWidgetState();
}

class _SubjectWidgetState extends State<SubjectWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        var detail = widget._subjectData.detail;

        if (detail.isEmpty) {
          showToast("상세 정보가 없어요.\n현재 학기 성적 새로고침 후 시도해주세요.");
          return;
        }

        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (BuildContext context, StateSetter setStateDialog) {
              return Dialog(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 25, 20, 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListView(
                        shrinkWrap: true,
                        children: [
                          Table(
                            border: TableBorder.all(),
                            children: detail.keys
                                .map((e) => TableRow(
                                      children: [
                                        TableCell(
                                          verticalAlignment: TableCellVerticalAlignment.middle,
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            child: SelectableText(
                                              e,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment: TableCellVerticalAlignment.middle,
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            child: SelectableText(
                                              detail[e]!,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("닫기"),
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: IntrinsicHeight(
          child: Container(
            decoration: BoxDecoration(
              color: globals.isLightMode ? Colors.white : Colors.black.withOpacity(0.45),
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
                          ),
                          softWrap: true,
                        ),
                        Text(
                          "${widget._subjectData.professor.isNotEmpty && (!widget._exportImage || widget._showSubject) ? "${widget._subjectData.professor} · " : ""}${widget._subjectData.credit.toStringAsPrecision(1)}학점",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: globals.isLightMode ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.8),
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
          ),
        ),
      ),
    );
  }
}
