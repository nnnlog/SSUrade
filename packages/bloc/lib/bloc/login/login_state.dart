part of 'login_bloc.dart';

@immutable
sealed class LoginState extends Equatable {
  final String id;
  final String password;

  const LoginState({
    required this.id,
    required this.password,
  });

  @override
  List<Object> get props => [id, password];
}

final class LoginTyping extends LoginState {
  const LoginTyping({required super.id, required super.password});

  factory LoginTyping.defaults() => LoginTyping(id: '', password: '');
}

final class LoginLoading extends LoginState {
  const LoginLoading({required super.id, required super.password});
}

final class LoginFailure extends LoginState {
  final String message;

  const LoginFailure({
    required this.message,
    required super.id,
    required super.password,
  });

  @override
  List<Object> get props => super.props + [message];
}

final class LoginSuccess extends LoginState {
  const LoginSuccess({required super.id, required super.password});
}
