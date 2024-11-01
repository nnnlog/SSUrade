import 'package:flutter/material.dart';
import 'package:ssurade/components/common/custom_app_bar.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("SSUrade"),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () async {
                  Navigator.pushNamed(context, "/login");
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                child: const Text("로그인"),
              ),
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
    );
  }
}
