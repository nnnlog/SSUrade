import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ssurade/components/common/custom_app_bar.dart';
import 'package:ssurade_application/ssurade_application.dart';
import 'package:ssurade_bloc/ssurade_bloc.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final TextEditingController _backgroundIntervalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingBloc(
        settingViewModelUseCase: context.read<SettingViewModelUseCase>(),
        absentViewModelUseCase: context.read<AbsentViewModelUseCase>(),
        chapelViewModelUseCase: context.read<ChapelViewModelUseCase>(),
        subjectViewModelUseCase: context.read<SubjectViewModelUseCase>(),
        loginViewModelUseCase: context.read<LoginViewModelUseCase>(),
        scholarshipViewModelUseCase: context.read<ScholarshipViewModelUseCase>(),
      ),
      child: BlocSelector<SettingBloc, SettingState, int>(selector: (state) => state is SettingShowing ? state.setting.backgroundInterval : -1, builder: (context, backgroundIntervalState) {
        if (backgroundIntervalState != -1) {
          _backgroundIntervalController.text = backgroundIntervalState.toString();
        }
        return BlocBuilder<SettingBloc, SettingState>(builder: (context, state) {
          return switch (state) {
            SettingInitial() => run(() {
              context.read<SettingBloc>().add(SettingReady());
              return Container();
            }),
            SettingShowing() => Scaffold(
              appBar: customAppBar("설정"),
              body: Padding(
                padding: const EdgeInsets.all(30),
                child: Center(
                  child: ListView(
                    children: <Widget>[
                      SwitchListTile(
                        value: state.setting.refreshInformationAutomatically,
                        onChanged: (value) {
                          context.read<SettingBloc>().add(SettingChanged(state.setting.copyWith(refreshInformationAutomatically: value)));
                        },
                        title: const Text("최신 학사 정보 자동으로 불러오기"),
                      ),
                      SwitchListTile(
                        value: state.setting.enableBackgroundFeature,
                        onChanged: (value) {
                          context.read<SettingBloc>().add(SettingChanged(state.setting.copyWith(enableBackgroundFeature: value)));
                        },
                        title: const Text("학사 정보 변경 알림 (백그라운드)"),
                      ),
                      SwitchListTile(
                        value: state.setting.showGradeInBackground,
                        onChanged: (value) {
                          context.read<SettingBloc>().add(SettingChanged(state.setting.copyWith(showGradeInBackground: value)));
                        },
                        title: const Text("학사 정보 변경 알림 - 성적 보이기"),
                      ),
                      run(() {
                        var onChanged = () {
                          var temp = int.tryParse(_backgroundIntervalController.text);
                          if (temp == null || temp < 1) {
                            context.read<SettingBloc>().add(SettingToastMessageRequested("올바른 값을 입력하세요."));
                            return;
                          }
                          context.read<SettingBloc>().add(SettingChanged(state.setting.copyWith(backgroundInterval: temp)));
                        };
                        return TextField(
                          controller: _backgroundIntervalController,
                          decoration: const InputDecoration(labelText: "학사 정보 변경 알림 - 확인 주기 (최솟값 : 15분)"),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onTapOutside: (event) => onChanged(),
                          onEditingComplete: () => onChanged(),
                        );
                      }),
                      const SizedBox(
                        height: 10,
                        width: 1,
                      ),
                    ] +
                        (state.isLogined
                            ? [
                          (SettingJobType.loadGradeInformation, "전체 학기 성적 불러오기"),
                          (SettingJobType.removeGradeInformation, "성적 정보 삭제"),
                          (SettingJobType.loadAbsentInformation, "유고 결석 정보 불러오기"),
                          (SettingJobType.removeAbsentInformation, "유고 결석 정보 삭제"),
                          (SettingJobType.loadChapelInformation, "전체 학기 채플 불러오기"),
                          (SettingJobType.removeChapelInformation, "전체 학기 채플 불러오기"),
                          (SettingJobType.validateCredential, "현재 로그인 정보 확인"),
                          (SettingJobType.logout, "로그아웃"),
                        ].map((e) {
                          return OutlinedButton(
                            onPressed: () async {
                              context.read<SettingBloc>().add(SettingJobRequested(e.$1));
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                            ),
                            child: Text(e.$2),
                          );
                        }).toList()
                            : []),
                  ),
                ),
              ),
            ),
          };
        });
      })
    );
  }
}
