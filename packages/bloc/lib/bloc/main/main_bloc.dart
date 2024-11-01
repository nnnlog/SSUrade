import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ssurade_application/ssurade_application.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  final LoginViewModelUseCase _loginViewModelUseCase;

  MainBloc({
    required LoginViewModelUseCase loginViewModelUseCase,
  })  : _loginViewModelUseCase = loginViewModelUseCase,
        super(MainInitial()) {
    on<MainReady>((event, emit) {
      _loginViewModelUseCase.getCredential().then((res) {
        emit(MainShowing(res != null && res != Credential.empty()));
      });

      return emit.forEach(_loginViewModelUseCase.getCredentialStream(), onData: (data) {
        return MainShowing(data != Credential.empty());
      });
    });
  }
}
