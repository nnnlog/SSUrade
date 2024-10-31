import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ssurade/components/common/custom_app_bar.dart';
import 'package:ssurade_application/ssurade_application.dart';
import 'package:ssurade_bloc/bloc/chapel/chapel_bloc.dart';

class ChapelPage extends StatefulWidget {
  const ChapelPage({super.key});

  @override
  State<StatefulWidget> createState() => _ChapelPageState();
}

class _ChapelPageState extends State<ChapelPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<ChapelPage> {
  final RefreshController _refreshController = RefreshController();
  late TabController _tabController;
  final Map<ChapelAttendance, ExpansionTileController> _expansionTileController = {};

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => ChapelBloc(
        chapelViewModelUseCase: context.read<ChapelViewModelUseCase>(),
        settingViewModelUseCase: context.read<SettingViewModelUseCase>(),
      ),
      child: BlocSelector<ChapelBloc, ChapelState, bool>(
        selector: (state) {
          return state is ChapelShowing;
        },
        builder: (context, isShowingChapel) {
          return Scaffold(
            appBar: customAppBar("채플 정보 조회"),
            backgroundColor: isShowingChapel ? const Color.fromRGBO(241, 242, 245, 1) : null,
            body: BlocBuilder<ChapelBloc, ChapelState>(builder: (context, state) {
              return switch (state) {
                ChapelInitial() => run(() {
                    context.read<ChapelBloc>().add(ChapelReady());
                    return Container();
                  }),
                ChapelInitialLoading() => run(() {
                    context.read<ChapelBloc>().add(ChapelAllInformationRequested());
                    return const Padding(
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
                    );
                  }),
                ChapelShowing() => SmartRefresher(
                    controller: _refreshController,
                    onRefresh: () {
                      context.read<ChapelBloc>().add(ChapelInformationRefreshRequested(state.showingYearSemester));
                    },
                    child: BlocListener<ChapelBloc, ChapelState>(
                      listener: (context, state) {
                        if (state is ChapelShowing) {
                          _refreshController.refreshCompleted();
                        }
                      },
                      child: Container(
                        color: const Color.fromRGBO(241, 242, 245, 1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            // Text(state.showingChapel.toString()),
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
                                        items: state.chapelManager.data.values
                                            .map((element) => DropdownMenuItem(
                                                  value: element.currentSemester,
                                                  child: Text(
                                                    "${element.currentSemester.year}학년도 ${element.currentSemester.semester.displayText}",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: "Pretendard",
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                        value: state.showingYearSemester,
                                        onChanged: (value) {
                                          if (value is YearSemester) {
                                            context.read<ChapelBloc>().add(ChapelYearSemesterSelected(value));
                                          }
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
                                        onPressed: () {
                                          context.read<ChapelBloc>().add(ChapelInformationRefreshRequested(state.showingYearSemester));
                                        },
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
                                          color: Colors.black,
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
                                              color: Colors.black.withOpacity(0.6),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.baseline,
                                            textBaseline: TextBaseline.alphabetic,
                                            children: [
                                              Text(
                                                state.showingChapel.attendCount.toString(),
                                                style: const TextStyle(
                                                  fontSize: 50,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 3,
                                              ),
                                              Text(
                                                "/ ${state.showingChapel.passAttendCount.toString()}",
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
                                      Column(
                                        children: [("결석 횟수", state.showingChapel.absentCount.toString()), ("강의 횟수", state.showingChapel.attendances.length.toString())]
                                            .map((e) => Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      e.$1,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black.withOpacity(0.6),
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                    Text(
                                                      e.$2,
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
                                          [("과목 코드", state.showingChapel.subjectCode), ("강의실", state.showingChapel.subjectPlace), ("강의 시간", state.showingChapel.subjectTime)],
                                          [("자리 층수", state.showingChapel.floor), ("좌석 번호", state.showingChapel.seatNo)],
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
                                            ...state.showingChapel.attendances.values.map((e) => Container(
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
                                                            e.displayAttendance.displayText,
                                                            style: TextStyle(color: e.displayAttendance.color, fontWeight: FontWeight.w500),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    childrenPadding: const EdgeInsets.fromLTRB(40, 10, 40, 20),
                                                    children: [
                                                      ...[
                                                        ("강의 구분", e.lectureType),
                                                        ("강사", e.lecturer),
                                                        ("소속", e.affiliation.isEmpty ? "-" : e.affiliation),
                                                        ("강의명", e.lectureName),
                                                        ("입력된 출결 상태", e.displayAttendance.displayText),
                                                        ("비고", e.lectureEtc.isEmpty ? "-" : e.lectureEtc),
                                                      ].map((e) => Container(
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
                                                            items: ChapelAttendanceStatus.values
                                                                .map((value) => DropdownMenuItem(
                                                                      value: value,
                                                                      child: Text(
                                                                        value == ChapelAttendanceStatus.unknown ? "지정하지 않음" : value.displayText,
                                                                        textAlign: TextAlign.right,
                                                                        style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: "Pretendard", fontStyle: FontStyle.italic),
                                                                      ),
                                                                    ))
                                                                .toList(),
                                                            onChanged: (ChapelAttendanceStatus? value) {
                                                              if (value != null) {
                                                                context.read<ChapelBloc>().add(ChapelOverwrittenAttendanceChanged(e, value));
                                                              }
                                                            },
                                                            value: e.overwrittenStatus,
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
                  ),
              };
            }),
          );
        },
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

extension on ChapelAttendanceStatus {
  Color get color {
    if (this == ChapelAttendanceStatus.attend) return Colors.green;
    if (this == ChapelAttendanceStatus.absent) return Colors.redAccent;
    return Colors.black54;
  }
}
