import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ssurade/components/common/custom_app_bar.dart';
import 'package:ssurade_adaptor/ssurade_adaptor.dart';
import 'package:ssurade_application/ssurade_application.dart';
import 'package:ssurade_bloc/ssurade_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("로그인"),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: AutofillGroup(
          child: Center(
            child: BlocProvider(
              create: (context) => LoginBloc(loginViewModelUseCase: getIt<LoginViewModelUseCase>()),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BlocListener<LoginBloc, LoginState>(
                    listener: (context, state) {
                      if (state is LoginSuccess) {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(),
                  ),
                  _LoginInput(),
                  Container(
                    height: 10,
                  ),
                  _LoginPassword(),
                  _LoginButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginInput extends StatelessWidget {
  const _LoginInput({super.key});

  @override
  build(BuildContext context) {
    return Flexible(
      child: TextFormField(
        decoration: const InputDecoration(hintText: "유세인트 아이디(학번)를 입력하세요."),
        autofillHints: const [AutofillHints.username],
        onChanged: (text) {
          context.read<LoginBloc>().add(LoginIdChanged(text));
        },
      ),
    );
  }
}

class _LoginPassword extends StatelessWidget {
  const _LoginPassword({super.key});

  @override
  build(BuildContext context) {
    return Flexible(
      child: TextFormField(
        decoration: const InputDecoration(hintText: "유세인트 비밀번호를 입력하세요."),
        obscureText: true,
        autofillHints: const [AutofillHints.password],
        onChanged: (text) {
          context.read<LoginBloc>().add(LoginPasswordChanged(text));
        },
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({super.key});

  @override
  build(BuildContext context) {
    final state = context.watch<LoginBloc>().state;
    return Flexible(
      child: TextButton(
        onPressed: state is LoginLoading
            ? null
            : () async {
                context.read<LoginBloc>().add(LoginRequested());
              },
        style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(40),
        ),
        child: Text(state is LoginLoading ? "로그인하는 중..." : "로그인"),
      ),
    );
  }
}
