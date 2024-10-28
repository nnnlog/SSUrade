import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:screenshot/screenshot.dart';
import 'package:ssurade/components/common/custom_app_bar.dart';
import 'package:ssurade/components/grade/grade_page_header.dart';
import 'package:ssurade/components/grade/subject_widget.dart';
import 'package:ssurade_application/port/in/viewmodel/subject_view_model_use_case.dart';
import 'package:ssurade_bloc/exports.dart';

class GradePage extends StatefulWidget {
  const GradePage({super.key});

  @override
  State<StatefulWidget> createState() => _GradePageState();
}

class _GradePageState extends State<GradePage> {
  // late SemesterSubjects _semesterSubjects;
  final RefreshController _refreshController = RefreshController();

  final ScreenshotController _screenshotController = ScreenshotController();

  void showScreenshotDialog(BuildContext context) {
    var exported = false;
    showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 20, 15),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "이미지로 내보내기",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    BlocSelector<GradeBloc, GradeState, bool>(
                      bloc: context.read<GradeBloc>(),
                      selector: (state) => state is GradeShowing && state.isDisplayRankingDuringExporting,
                      builder: (context, isDisplayRankingDuringExporting) {
                        return SwitchListTile(
                          value: isDisplayRankingDuringExporting,
                          onChanged: (value) {},
                          dense: true,
                          title: const Text("석차"),
                        );
                      },
                    ),
                    BlocSelector<GradeBloc, GradeState, bool>(
                      bloc: context.read<GradeBloc>(),
                      selector: (state) => state is GradeShowing && state.isDisplaySubjectInformationDuringExporting,
                      builder: (context, isDisplaySubjectInformationDuringExporting) {
                        return SwitchListTile(
                          value: isDisplaySubjectInformationDuringExporting,
                          onChanged: (value) {},
                          dense: true,
                          title: const Text("과목 정보"),
                        );
                      },
                    ),
                    Row(
                      children: [
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            context.read<GradeBloc>().add(GradeExportRequested());
                          },
                          child: const Text("내보내기"),
                        ),
                        BlocListener<GradeBloc, GradeState>(
                          bloc: context.read<GradeBloc>(),
                          listener: (_, state) async {
                            if (state is GradeShowing && state.isExporting) {
                              final bytes = await _screenshotController.capture();
                              exported = true;
                              context.read<GradeBloc>().add(GradeScreenshotSaveRequested(bytes!));
                            }
                            if (state is GradeShowing && !state.isExporting && exported) {
                              Navigator.pop(context);
                            }
                          },
                          child: Container(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GradeBloc(subjectViewModelUseCase: context.read<SubjectViewModelUseCase>()),
      child: BlocSelector<GradeBloc, GradeState, bool>(
        selector: (state) {
          return state is GradeShowing;
        },
        builder: (context, isShowingGrade) {
          return Scaffold(
            appBar: customAppBar("학기별 성적 조회"),
            backgroundColor: isShowingGrade ? const Color.fromRGBO(241, 242, 245, 1) : null,
            body: BlocBuilder<GradeBloc, GradeState>(builder: (context, state) {
              return switch (state) {
                GradeInitial() => run(() {
                    context.read<GradeBloc>().add(GradeReady());
                    return Container();
                  }),
                GradeInitialLoading() => run(() {
                    context.read<GradeBloc>().add(GradeAllInformationRequested());
                    return Padding(
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
                            Text("전체 학기 성적을 불러오고 있어요..."),
                          ],
                        ),
                      ),
                    );
                  }),
                GradeShowing() => SmartRefresher(
                    controller: _refreshController,
                    onRefresh: () async {
                      context.read<GradeBloc>().add(GradeInformationRefreshRequested(state.showingSemester));
                    },
                    child: BlocListener<GradeBloc, GradeState>(
                      listener: (context, state) {
                        if (state is GradeShowing) {
                          _refreshController.refreshCompleted();
                        }
                      },
                      child: SingleChildScrollView(
                        child: Screenshot(
                          controller: _screenshotController,
                          child: Container(
                            color: const Color.fromRGBO(241, 242, 245, 1),
                            child: Column(
                              children: <Widget>[
                                    GradePageHeader(),
                                  ] +
                                  context.select((GradeBloc bloc) => bloc.state).let(
                                    (state) {
                                      if (state is GradeShowing) {
                                        return state.semesterSubjectsManager.data[state.showingSemester]?.subjects.values.toList().also((it) {
                                              it.sort();
                                            }).map((e) {
                                              return SubjectWidget(e, state.isExporting, state.isDisplaySubjectInformationDuringExporting);
                                            }).toList() ??
                                            [];
                                      } else {
                                        return [];
                                      }
                                    },
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
              };
            }),
            floatingActionButton: BlocBuilder<GradeBloc, GradeState>(builder: (context, state) {
              if (state is GradeShowing) {
                return FloatingActionButton(
                  onPressed: () async {
                    showScreenshotDialog(context);
                  },
                  child: const Icon(Icons.image),
                );
              } else {
                return Container();
              }
            }),
          );
        },
      ),
    );
  }
}
