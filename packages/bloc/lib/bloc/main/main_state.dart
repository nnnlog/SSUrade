part of 'main_bloc.dart';

@immutable
sealed class MainState {}

final class MainInitial extends MainState {}

final class MainAgree extends MainState {
  final String agreementShort;
  final String agreement;

  MainAgree(this.agreementShort, this.agreement);
}

final class MainShowing extends MainState {
  final bool isLogin;

  MainShowing(this.isLogin);
}
