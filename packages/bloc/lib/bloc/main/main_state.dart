part of 'main_bloc.dart';

@immutable
sealed class MainState {}

final class MainInitial extends MainState {}

final class MainShowing extends MainState {
  final bool isLogin;

  MainShowing(this.isLogin);
}
