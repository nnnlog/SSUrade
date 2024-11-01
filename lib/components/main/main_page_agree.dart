import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ssurade/components/common/custom_app_bar.dart';
import 'package:ssurade/components/common/show_scrollabe_dialog.dart';
import 'package:ssurade_bloc/ssurade_bloc.dart';

class MainPageAgree extends StatelessWidget {
  final String _agreement_short;
  final String _agreement;

  const MainPageAgree({
    Key? key,
    required String agreement_short,
    required String agreement,
  })  : _agreement_short = agreement_short,
        _agreement = agreement,
        super(key: key);

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
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "SSUrade 개인정보 처리방침",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SingleChildScrollView(
                      child: Text(_agreement_short),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                      ),
                      onPressed: () {
                        showScrollableDialog(
                          context,
                          [
                            SingleChildScrollView(
                              child: SelectableText(_agreement),
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
                        );
                      },
                      child: const Text(
                        "전체 보기",
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        context.read<MainBloc>().add(MainDisagreeEvent());
                      },
                      child: const Text("닫기"),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        context.read<MainBloc>().add(MainAgreeEvent());
                      },
                      child: const Text("동의 후 계속하기"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
