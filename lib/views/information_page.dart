import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ssurade/components/common/custom_app_bar.dart';
import 'package:ssurade_application/ssurade_application.dart';
import 'package:ssurade_bloc/bloc/app_version/app_version_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({super.key});

  @override
  State<StatefulWidget> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppVersionBloc(appVersionViewModelUseCase: context.read<AppVersionViewModelUseCase>()),
      child: Scaffold(
        appBar: customAppBar("앱 정보"),
        body: BlocBuilder<AppVersionBloc, AppVersionState>(
          builder: (context, state) {
            if (state is AppVersionInitial) {
              context.read<AppVersionBloc>().add(AppVersionCheckRequested());
              return Container();
            }

            String appVer = "불러오는 중...", newVer = "-", devVer = "", buildNum = "불러오는 중...";
            if (state is AppVersionShowing) {
              appVer = state.version.appVersion;
              newVer = state.version.newVersion;
              devVer = state.version.devVersion;
              buildNum = state.version.buildNumber;
            }

            return Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SSUrade",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    "숭실대 학생들을 위한 학사 정보 조회 애플리케이션",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "앱 버전 : $appVer (빌드 번호 : $buildNum)",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  (newVer == "-"
                      ? const Text("버전 불러오는 중...")
                      : Row(
                          children: [
                            (newVer == ""
                                ? const Text(
                                    "최신 버전이에요.",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.blueAccent,
                                    ),
                                  )
                                : InkWell(
                                    child: Text(
                                      "버전 $newVer으로 업데이트할 수 있어요.",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.deepOrangeAccent,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    onTap: () => launchUrl(
                                      Uri.parse("https://github.com/nnnlog/ssurade/releases/tag/v$newVer"),
                                      mode: LaunchMode.inAppBrowserView,
                                    ),
                                  )),
                            const Text(" "),
                            (devVer == ""
                                ? const Text("")
                                : InkWell(
                                    child: Text(
                                      "(베타 버전 : $devVer)",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    onTap: () => launchUrl(
                                      Uri.parse("https://github.com/nnnlog/ssurade/releases/tag/v$devVer"),
                                      mode: LaunchMode.inAppBrowserView,
                                    ),
                                  )),
                          ],
                        )),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      InkWell(
                        child: const Text(
                          "Github",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () => launchUrl(
                          Uri.parse("https://github.com/nnnlog/ssurade"),
                          mode: LaunchMode.inAppBrowserView,
                        ),
                      ),
                      const Text(
                        "에서 오픈소스로 개발하고 있습니다.",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Wrap(
                    children: [
                      const Text(
                        "오류 보고나 기능 추가 등의 문의는 ",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      InkWell(
                        child: const Text(
                          "Github Issue",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () => launchUrl(
                          Uri.parse("https://github.com/nnnlog/ssurade/issues"),
                          mode: LaunchMode.inAppBrowserView,
                        ),
                      ),
                      const Text(
                        "나",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      InkWell(
                        child: const Text(
                          "me@nlog.dev",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () {
                          Clipboard.setData(const ClipboardData(text: "me@nlog.dev"));
                        },
                      ),
                      const Text(
                        "에 남겨주세요.",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Divider(),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      const Text(
                        "Developed by ",
                      ),
                      InkWell(
                        child: const Text(
                          "박찬솔 (nlog)",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () => launchUrl(
                          Uri.parse("https://nlog.dev/"),
                          mode: LaunchMode.inAppBrowserView,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  const Row(
                    children: [
                      Text(
                        "Designed by ",
                      ),
                      InkWell(
                        child: Text(
                          "이지헌",
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
