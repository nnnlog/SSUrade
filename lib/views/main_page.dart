import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ssurade/components/common/custom_app_bar.dart';
import 'package:ssurade/components/main/main_page_agree.dart';
import 'package:ssurade_application/ssurade_application.dart';
import 'package:ssurade_bloc/bloc/main/main_bloc.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainBloc(
        loginViewModelUseCase: context.read<LoginViewModelUseCase>(),
        settingViewModelUseCase: context.read<SettingViewModelUseCase>(),
        mainViewModelUseCase: context.read<MainViewModelUseCase>(),
      ),
      child: BlocBuilder<MainBloc, MainState>(builder: (context, state) {
        return switch (state) {
          MainInitial() => run(() {
              context.read<MainBloc>().add(MainReady());
              return Container();
            }),
          MainAgree() => MainPageAgree(
              agreement_short: state.agreementShort,
              agreement: state.agreement,
            ),
          MainShowing() => Scaffold(
              appBar: customAppBar("SSUrade"),
              body: Padding(
                padding: const EdgeInsets.all(30),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: (!state.isLogin
                            ? [
                                OutlinedButton(
                                  onPressed: () async {
                                    Navigator.pushNamed(context, "/login");
                                  },
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(40),
                                  ),
                                  child: const Text("로그인"),
                                ),
                              ]
                            : [
                                OutlinedButton(
                                  onPressed: () async {
                                    Navigator.pushNamed(context, "/grade");
                                  },
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(40),
                                  ),
                                  child: const Text("학기별 성적 조회"),
                                ),
                                OutlinedButton(
                                  onPressed: () async {
                                    Navigator.pushNamed(context, "/grade_statistics");
                                  },
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(40),
                                  ),
                                  child: const Text("성적 통계 조회"),
                                ),
                                OutlinedButton(
                                  onPressed: () async {
                                    Navigator.pushNamed(context, "/grade_statistics_category");
                                  },
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(40),
                                  ),
                                  child: const Text("이수구분별 성적 통계 조회"),
                                ),
                                OutlinedButton(
                                  onPressed: () async {
                                    Navigator.pushNamed(context, "/chapel");
                                  },
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(40),
                                  ),
                                  child: const Text("채플 정보 조회"),
                                ),
                                OutlinedButton(
                                  onPressed: () async {
                                    Navigator.pushNamed(context, "/scholarship");
                                  },
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(40),
                                  ),
                                  child: const Text("장학 정보 조회"),
                                ),
                                OutlinedButton(
                                  onPressed: () async {
                                    Navigator.pushNamed(context, "/absent");
                                  },
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(40),
                                  ),
                                  child: const Text("유고 결석 정보 조회"),
                                ),
                              ]) +
                        [
                          OutlinedButton(
                            onPressed: () async {
                              Navigator.pushNamed(context, "/setting");
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                            ),
                            child: const Text("설정"),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              Navigator.pushNamed(context, "/information");
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                            ),
                            child: const Text("정보"),
                          ),
                        ],
                  ),
                ),
              ),
            ),
        };
      }),
    );
  }
}
