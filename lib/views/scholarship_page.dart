import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ssurade/components/common/custom_app_bar.dart';
import 'package:ssurade/components/common/key_value_data.dart';
import 'package:ssurade/crawling/common/crawler.dart';
import 'package:ssurade/crawling/error/no_data_exception.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/etc/progress.dart';
import 'package:ssurade/types/scholarship/scholarship_manager.dart';
import 'package:ssurade/utils/toast.dart';

class ScholarshipPage extends StatefulWidget {
  const ScholarshipPage({super.key});

  @override
  State<StatefulWidget> createState() => _ScholarshipPage();
}

class _ScholarshipPage extends State<ScholarshipPage> {
  final RefreshController _refreshController = RefreshController();

  GradeProgress _progress = GradeProgress.init;
  bool _lockedForRefresh = false;

  Future<void> refreshData() async {
    if (_lockedForRefresh) return;
    _lockedForRefresh = true;

    showToast("장학 정보를 불러오는 중이에요...");

    try {
      ScholarshipManager data = await Crawler.getScholarship().execute();

      if (data.isEmpty) throw NoDataException();

      globals.scholarshipManager = data;
      globals.scholarshipManager.saveFile();

      if (!mounted) return;

      showToast("장학 정보를 불러왔어요.");
    } catch (_) {
      if (mounted) {
        showToast("장학 정보를 불러오지 못했어요.");
      }
    } finally {
      _lockedForRefresh = false;
    }
  }

  refreshDataWithPull() async {
    await refreshData();

    _refreshController.loadComplete();
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();

    (() async {
      bool needRefresh = true;
      if (globals.scholarshipManager.isEmpty) {
        needRefresh = false;

        ScholarshipManager res;
        try {
          res = await Crawler.getScholarship().execute();
        } catch (_) {
          if (mounted) {
            Navigator.pop(context);
          }
          showToast("장학 정보가 없거나 가져오지 못했어요.\n다시 시도해주세요.");
          return;
        }

        globals.scholarshipManager = res;
        globals.scholarshipManager.saveFile(); // saving file does not need await
      }

      if (globals.scholarshipManager.isEmpty) {
        if (mounted) {
          Navigator.pop(context);
        }
        showToast("장학 정보가 없거나 가져오지 못했어요.");
        return;
      }

      setState(() {
        _progress = GradeProgress.finish;
      });

      if (needRefresh && globals.setting.refreshGradeAutomatically) {
        refreshData();
      }
    })();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("장학 정보 조회"),
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
                    Text("장학 정보를 불러오고 있어요..."),
                  ],
                ),
              ),
            )
          : SmartRefresher(
              controller: _refreshController,
              onRefresh: refreshDataWithPull,
              child: Container(
                color: globals.isLightMode ? (_progress == GradeProgress.init ? null : const Color.fromRGBO(241, 242, 245, 1)) : null,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: KeyValueTable(
                      map: Map.fromEntries(
                        globals.scholarshipManager.data.map(
                          (e) => MapEntry("${e.name}\n(${e.when.display})", "${e.process}\n(${e.price}원)"),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: refreshData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
