part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

final class LoginRequested extends LoginEvent {}

final class LoginIdChanged extends LoginEvent {
  final String id;

  LoginIdChanged(this.id);
}

final class LoginPasswordChanged extends LoginEvent {
  final String password;

  LoginPasswordChanged(this.password);
}
