import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ssurade/components/common/custom_app_bar.dart';
import 'package:ssurade/crawling/common/crawler.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/absent/absent_application_information.dart';
import 'package:ssurade/types/etc/progress.dart';
import 'package:ssurade/utils/toast.dart';
import 'package:tuple/tuple.dart';

class AbsentPage extends StatefulWidget {
  const AbsentPage({super.key});

  @override
  State<StatefulWidget> createState() => _AbsentPageState();
}

class _AbsentPageState extends State<AbsentPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<AbsentPage> {
  final RefreshController _refreshController = RefreshController();
  final Map<AbsentApplicationInformation, ExpansionTileController> _expansionTileController = {};

  GradeProgress _progress = GradeProgress.init;
  bool _lockedForRefresh = false;

  Future<void> refreshAbsentInformation() async {
    if (_lockedForRefresh) return;

    _lockedForRefresh = true;
    showToast("이번 학기 유고 결석 정보를 불러오는 중이에요...");

    try {
      List<AbsentApplicationInformation> data = await Crawler.singleAbsentBySemester().execute();

      globals.absentApplicationManager.data = data;
      globals.absentApplicationManager.saveFile();

      if (!mounted) return;

      showToast("이번 학기 유고 결석 정보를 불러왔어요.");
    } catch (_) {
      if (mounted) {
        showToast("이번 학기 유고 결석 정보를 불러오지 못했어요.");
      }
    } finally {
      _lockedForRefresh = false;
    }
  }

  refreshAbsentInformationUsingPull() async {
    await refreshAbsentInformation();

    _refreshController.loadComplete();
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();

    (() async {
      bool needRefresh = true;
      if (globals.absentApplicationManager.isEmpty) {
        needRefresh = false;

        List<AbsentApplicationInformation> res;
        try {
          res = await Crawler.singleAbsentBySemester().execute();
        } catch (_) {
          if (mounted) {
            Navigator.pop(context);
          }
          showToast("채플 정보를 가져오지 못했어요.\n다시 시도해주세요.");
          return;
        }

        globals.absentApplicationManager.data = res;
        globals.absentApplicationManager.saveFile(); // saving file does not need await
      }

      if (globals.absentApplicationManager.isEmpty) {
        if (mounted) {
          Navigator.pop(context);
        }
        showToast("유고 결석 정보를 불러오지 못했거나 이번 학기에 신청한 유고 결석이 없어요.");
        return;
      }

      setState(() {
        _progress = GradeProgress.finish;
      });

      if (needRefresh && globals.setting.refreshGradeAutomatically) {
        refreshAbsentInformation();
      }
    })();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: customAppBar("유고 결석 정보 조회"),
      backgroundColor: globals.isLightMode ? (_progress == GradeProgress.init ? null : const Color.fromRGBO(241, 242, 245, 1)) : null,
      body: _progress == GradeProgress.init
          ? const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LinearProgressIndicator(),
                    SizedBox(
                      width: 1,
                      height: 15,
                    ),
                    Text("유고 결석 정보를 불러오고 있어요..."),
                  ],
                ),
              ),
            )
          : SmartRefresher(
              controller: _refreshController,
              onRefresh: refreshAbsentInformationUsingPull,
              // onLoading: refreshCurrentGradeWithPull,
              child: Container(
                margin: const EdgeInsets.only(top: 30),
                color: globals.isLightMode ? (_progress == GradeProgress.init ? null : const Color.fromRGBO(241, 242, 245, 1)) : null,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...globals.absentApplicationManager.data.map((e) => Container(
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
                              controller: _expansionTileController[e] ??= ExpansionTileController(),
                              shape: Border.all(width: 0, color: Colors.transparent),
                              title: Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      e.startDate == e.endDate ? e.startDate : "${e.startDate} ~ ${e.endDate}",
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      e.status,
                                      style: TextStyle(
                                          color: {
                                            "승인": Colors.green,
                                            "거부": Colors.redAccent,
                                          }[e.status],
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(40, 10, 40, 20),
                              children: [
                                ...[
                                  Tuple2("결석 구분", e.absentType),
                                  Tuple2("결석 사유", e.absentCause),
                                  Tuple2("신청 일자", e.applicationDate),
                                  Tuple2("처리 일자", e.proceedDate),
                                  Tuple2("거부 사유", e.rejectCause),
                                ].map((e) => Container(
                                      margin: const EdgeInsets.symmetric(vertical: 3),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            e.item1,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(color: Colors.black54),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Text(
                                              e.item2,
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(fontWeight: FontWeight.w500),
                                              softWrap: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            onPressed: () {
                              for (var controller in _expansionTileController.values) {
                                controller.expand();
                              }
                            },
                            child: const Text("전체 펼치기"),
                          ),
                          TextButton(
                            onPressed: () {
                              for (var controller in _expansionTileController.values) {
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
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: refreshAbsentInformation,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
