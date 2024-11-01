import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ssurade_application/ssurade_application.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  final LoginViewModelUseCase _loginViewModelUseCase;
  final SettingViewModelUseCase _settingViewModelUseCase;
  final MainViewModelUseCase _mainViewModelUseCase;

  MainBloc({
    required LoginViewModelUseCase loginViewModelUseCase,
    required SettingViewModelUseCase settingViewModelUseCase,
    required MainViewModelUseCase mainViewModelUseCase,
  })  : _loginViewModelUseCase = loginViewModelUseCase,
        _settingViewModelUseCase = settingViewModelUseCase,
        _mainViewModelUseCase = mainViewModelUseCase,
        super(MainInitial()) {
    on<MainReady>((event, emit) async {
      final setting = await _settingViewModelUseCase.getSetting() ?? Setting.defaults();
      if (!setting.agree) {
        final agreement = await _mainViewModelUseCase.getAgreement();
        final agreementShort = await _mainViewModelUseCase.getAgreementShort();

        emit(MainAgree(agreementShort, agreement));
      } else {
        await _loginViewModelUseCase.getCredential().then((res) {
          emit(MainShowing(res != null && res != Credential.empty()));
        });
      }

      return emit.forEach(_loginViewModelUseCase.getCredentialStream(), onData: (data) {
        if (state is MainAgree) return state;
        return MainShowing(data != Credential.empty());
      });
    });

    on<MainAgreeEvent>((event, emit) async {
      await _settingViewModelUseCase.applyNewSetting((await _settingViewModelUseCase.getSetting() ?? Setting.defaults()).copyWith(agree: true));

      await _loginViewModelUseCase.getCredential().then((res) {
        emit(MainShowing(res != null && res != Credential.empty()));
      });
    });

    on<MainDisagreeEvent>((event, emit) async {
      await _mainViewModelUseCase.showToast("약관에 동의해야 앱을 사용할 수 있어요.");
      _mainViewModelUseCase.exitApp();
    });
  }
}
