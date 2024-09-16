import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ssurade/components/common/custom_app_bar.dart';
import 'package:ssurade/crawling/common/crawler.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/chapel/chapel.dart';
import 'package:ssurade/types/chapel/chapel_attendance.dart';
import 'package:ssurade/types/chapel/chapel_attendance_status.dart';
import 'package:ssurade/types/chapel/chapel_manager.dart';
import 'package:ssurade/types/etc/progress.dart';
import 'package:ssurade/types/semester/semester.dart';
import 'package:ssurade/types/semester/year_semester.dart';
import 'package:ssurade/utils/set.dart';
import 'package:ssurade/utils/toast.dart';
import 'package:tuple/tuple.dart';

class ChapelPage extends StatefulWidget {
  const ChapelPage({super.key});

  @override
  State<StatefulWidget> createState() => _ChapelPageState();
}

class _ChapelPageState extends State<ChapelPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<ChapelPage> {
  late ChapelInformation _chapelInformation;
  final RefreshController _refreshController = RefreshController();
  late TabController _tabController;
  final Map<ChapelAttendanceInformation, ExpansionTileController> _expansionTileController = {};

  GradeProgress _progress = GradeProgress.init;
  final Set<YearSemester> _lockedForRefresh = {};

  void callbackSelectSubject(YearSemester value) {
    setState(() {
      _chapelInformation = globals.chapelInformationManager.data[value]!;
    });
  }

  Future<void> refreshCurrentChapel() async {
    var search = _chapelInformation.currentSemester;
    if (_lockedForRefresh.contains(search)) return;
    _lockedForRefresh.add(search);

    showToast("${search.year}학년도 ${search.semester.displayName} 채플 정보를 불러오는 중이에요...");

    try {
      ChapelInformation data = await Crawler.singleChapelBySemester(search).execute();

      var original = globals.chapelInformationManager.data[search];
      if (original != null) {
        ChapelInformation.merge(data, original);
      }

      globals.chapelInformationManager.data.remove(data);
      globals.chapelInformationManager.data.add(data);
      globals.chapelInformationManager.saveFile();

      if (!mounted) return;
      if (search != _chapelInformation.currentSemester) return;

      callbackSelectSubject(search);

      showToast("${search.year}학년도 ${search.semester.displayName} 채플 정보를 불러왔어요.");
    } catch (_) {
      if (mounted) {
        showToast("${search.year}학년도 ${search.semester.displayName} 채플 정보를 불러오지 못했어요.");
      }
    } finally {
      _lockedForRefresh.remove(search);
    }
  }

  refreshCurrentGradeWithPull() async {
    await refreshCurrentChapel();

    _refreshController.loadComplete();
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    if (globals.semesterSubjectsManager.isEmpty) {
      if (mounted) {
        Navigator.pop(context);
      }
      showToast("채플 정보를 가져오기 이전에 성적 정보를 먼저 불러와야 해요.");
      return;
    }

    (() async {
      bool needRefresh = true;
      if (globals.chapelInformationManager.isEmpty) {
        needRefresh = false;

        var search = <YearSemester>{};
        for (var value in globals.semesterSubjectsManager.data.values) {
          for (var subject in value.subjects.values) {
            if (subject.category == "채플" || subject.name == "CHAPEL") {
              search.add(value.currentSemester);
              break;
            }
          }
        }

        int year = DateTime.now().year;
        search.add(YearSemester(year, Semester.first));
        search.add(YearSemester(year, Semester.second));

        ChapelInformationManager res;
        try {
          res = await Crawler.allChapel(search.toList()).execute();
        } catch (_) {
          if (mounted) {
            Navigator.pop(context);
          }
          showToast("채플 정보를 가져오지 못했어요.\n다시 시도해주세요.");
          return;
        }

        globals.chapelInformationManager = res;
        globals.chapelInformationManager.saveFile(); // saving file does not need await
      }

      if (globals.chapelInformationManager.isEmpty) {
        if (mounted) {
          Navigator.pop(context);
        }
        showToast("채플 정보를 불러오지 못했거나 채플 정보가 없어요.");
        return;
      }

      callbackSelectSubject(globals.chapelInformationManager.data.last.currentSemester);
      setState(() {
        _progress = GradeProgress.finish;
      });

      if (needRefresh && globals.setting.refreshGradeAutomatically) {
        refreshCurrentChapel();
      }
    })();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: customAppBar("채플 정보 조회"),
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
                    Text("채플 정보를 불러오고 있어요..."),
                  ],
                ),
              ),
            )
          : SmartRefresher(
              controller: _refreshController,
              onRefresh: refreshCurrentGradeWithPull,
              // onLoading: refreshCurrentGradeWithPull,
              child: Container(
                color: globals.isLightMode ? (_progress == GradeProgress.init ? null : const Color.fromRGBO(241, 242, 245, 1)) : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    // Text(_chapelInformation.toString()),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DropdownButton(
                                items: globals.chapelInformationManager.data
                                    .map((element) => DropdownMenuItem(
                                          value: element.currentSemester,
                                          child: Text(
                                            "${element.currentSemester.year}학년도 ${element.currentSemester.semester.displayName}",
                                            style: TextStyle(
                                              color: globals.isLightMode ? Colors.black : Colors.white,
                                              fontFamily: "Pretendard",
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                value: _chapelInformation.currentSemester,
                                onChanged: (YearSemester? value) {
                                  setState(() {
                                    _chapelInformation = globals.chapelInformationManager.data[value!]!;
                                  });
                                },
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black.withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Pretendard",
                                ),
                                underline: Container(),
                                isDense: true,
                              ),
                              TextButton(
                                onPressed: refreshCurrentChapel,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(30, 30),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  textStyle: TextStyle(
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                ),
                                child: Icon(
                                  Icons.refresh,
                                  color: globals.isLightMode ? Colors.black : Colors.white,
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Pass까지 남은 출석",
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
                                        _chapelInformation.attendCount.toString(),
                                        style: const TextStyle(
                                          fontSize: 50,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 3,
                                      ),
                                      Text(
                                        "/ ${_chapelInformation.passAttendCount.toString()}",
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
                              Column(
                                children: [Tuple2("결석 횟수", _chapelInformation.absentCount.toString()), Tuple2("강의 횟수", _chapelInformation.attendances.length.toString())]
                                    .map((e) => Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              e.item1,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: globals.isLightMode ? Colors.black.withOpacity(0.6) : Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              e.item2,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: RichText(
                              textAlign: TextAlign.start,
                              text: const TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(
                                      Icons.info_outline_rounded,
                                      size: 12,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " 채플의 이수 기준은 2/3 이상의 출석입니다.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(
                            text: "강의 정보",
                          ),
                          Tab(
                            text: "출결 정보",
                          )
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: ListView(
                              children: [
                                ...[
                                  [Tuple2("과목 코드", _chapelInformation.subjectCode), Tuple2("강의실", _chapelInformation.subjectPlace), Tuple2("강의 시간", _chapelInformation.subjectTime)],
                                  [Tuple2("자리 층수", _chapelInformation.floor), Tuple2("좌석 번호", _chapelInformation.seatNo)],
                                ].map(
                                  (e) => Container(
                                    padding: const EdgeInsets.all(20),
                                    margin: const EdgeInsets.only(bottom: 20),
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
                                    child: Column(
                                      children: e
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
                                  ),
                                ),
                                Container(
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
                                    shape: Border.all(width: 0, color: Colors.transparent),
                                    title: const Text("자리 배치도 보기"),
                                    childrenPadding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                                    children: [
                                      GestureDetector(
                                        child: Image.asset("assets/image/chapel.jpg"),
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) {
                                            return FullScreenImage(Image.asset(
                                              "assets/image/chapel.jpg",
                                            ));
                                          }));
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(
                                          Icons.info_outline_rounded,
                                          size: 12,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      TextSpan(
                                        text: " 오류 또는 변경 사항으로 인해 실제 기준 또는 정보와 다를 수 있으니 참고용으로만 사용하세요. 앱 개발자는 앱에 표시되는 정보에 대하여 어떠한 책임도 지지 않습니다.",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(
                                          Icons.info_outline_rounded,
                                          size: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      TextSpan(
                                        text: " 자리 배치도 사진을 누르면 확대할 수 있어요.",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: ListView(
                              children: [
                                Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    ..._chapelInformation.attendances.map((e) => Container(
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
                                                    e.lectureDate,
                                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                                  ),
                                                  Text(
                                                    e.displayAttendance.display,
                                                    style: TextStyle(color: e.displayAttendance.color, fontWeight: FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            childrenPadding: const EdgeInsets.fromLTRB(40, 10, 40, 20),
                                            children: [
                                              ...[
                                                Tuple2("강의 구분", e.lectureType),
                                                Tuple2("강사", e.lecturer),
                                                Tuple2("소속", e.affiliation.isEmpty ? "-" : e.affiliation),
                                                Tuple2("강의명", e.lectureName),
                                                Tuple2("입력된 출결 상태", e.attendance.display),
                                                Tuple2("비고", e.lectureEtc.isEmpty ? "-" : e.lectureEtc),
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
                                                        Expanded(child: Container()),
                                                        Text(
                                                          e.item2,
                                                          textAlign: TextAlign.right,
                                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  const Text(
                                                    "출결 상태 강제 지정",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(color: Colors.black54),
                                                  ),
                                                  DropdownButton(
                                                    isDense: true,
                                                    alignment: AlignmentDirectional.centerEnd,
                                                    padding: EdgeInsets.zero,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 14,
                                                      fontFamily: "Pretendard",
                                                    ),
                                                    icon: Container(),
                                                    items: ChapelAttendance.values
                                                        .map((state) => DropdownMenuItem(
                                                              value: state,
                                                              child: Text(
                                                                state == ChapelAttendance.unknown ? "지정하지 않음" : state.display,
                                                                textAlign: TextAlign.right,
                                                                style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: "Pretendard", fontStyle: FontStyle.italic),
                                                              ),
                                                            ))
                                                        .toList(),
                                                    onChanged: (ChapelAttendance? value) {
                                                      setState(() {
                                                        e.overwrittenAttendance = value!;
                                                      });
                                                      globals.chapelInformationManager.saveFile();
                                                    },
                                                    value: e.overwrittenAttendance,
                                                  ),
                                                ],
                                              ),
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
                                const SizedBox(height: 10),
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(
                                          Icons.info_outline_rounded,
                                          size: 12,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      TextSpan(
                                        text: " 오류 또는 변경 사항으로 인해 실제 기준 또는 정보와 다를 수 있으니 참고용으로만 사용하세요. 앱 개발자는 앱에 표시되는 정보에 대하여 어떠한 책임도 지지 않습니다.",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(
                                          Icons.info_outline_rounded,
                                          size: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      TextSpan(
                                        text: " '출결 상태 강제 지정'은 앱에서 표시되는 출결 상태만 변경하는 것으로 중간고사 기간의 비대면 채플이 출결 처리 되기 이전에 출석으로 표시될 수 있게끔 설계한 기능이에요.",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class FullScreenImage extends StatelessWidget {
  final Image image;

  const FullScreenImage(this.image, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
            tag: 'image_fullscreen',
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InteractiveViewer(
                  // panEnabled: false,
                  maxScale: 5,
                  minScale: 1,
                  child: image,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("닫기"),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
