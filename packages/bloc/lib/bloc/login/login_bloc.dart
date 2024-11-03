import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:ssurade_application/ssurade_application.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginViewModelUseCase _loginViewModelUseCase;

  LoginBloc({
    required LoginViewModelUseCase loginViewModelUseCase,
  })  : _loginViewModelUseCase = loginViewModelUseCase,
        super(LoginTyping.defaults()) {
    on<LoginRequested>(_onLoginRequested);
    on<LoginIdChanged>(_onLoginIdChanged);
    on<LoginPasswordChanged>(_onLoginPasswordChanged);
  }

  void _onLoginRequested(LoginRequested event, Emitter<LoginState> emit) async {
    final currentState = state;
    if (currentState is LoginLoading) {
      return;
    }

    emit(LoginLoading(id: currentState.id, password: currentState.password));

    final result = await _loginViewModelUseCase.loadNewCredential(Credential(id: currentState.id, password: currentState.password));
    if (result) {
      emit(LoginSuccess(
        id: currentState.id,
        password: currentState.password,
      ));
    } else {
      _loginViewModelUseCase.showToast("로그인을 실패했어요.\n학번이나 비밀번호, 네트워크 상태를 확인해주세요.");
      emit(LoginTyping(
        id: currentState.id,
        password: currentState.password,
      ));
    }
  }

  void _onLoginIdChanged(LoginIdChanged event, Emitter<LoginState> emit) {
    final currentState = state;
    emit(LoginTyping(id: event.id, password: currentState.password));
  }

  void _onLoginPasswordChanged(LoginPasswordChanged event, Emitter<LoginState> emit) {
    final currentState = state;
    emit(LoginTyping(id: currentState.id, password: event.password));
  }
}
