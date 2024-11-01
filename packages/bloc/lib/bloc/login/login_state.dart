part of 'login_bloc.dart';

@immutable
sealed class LoginState extends Equatable {
  final String id;
  final String password;

  LoginState({
    required this.id,
    required this.password,
  });

  @override
  List<Object> get props => [id, password];
}

final class LoginTyping extends LoginState {
  LoginTyping({required super.id, required super.password});

  factory LoginTyping.defaults() => LoginTyping(id: '', password: '');
}

final class LoginLoading extends LoginState {
  LoginLoading({required super.id, required super.password});
}

final class LoginSuccess extends LoginState {
  LoginSuccess({required super.id, required super.password});
}
