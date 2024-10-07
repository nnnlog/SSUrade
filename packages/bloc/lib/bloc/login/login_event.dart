part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

final class LoginRequested extends LoginEvent {}

final class LoginFailed extends LoginEvent {}

final class LoginSucceeded extends LoginEvent {}
