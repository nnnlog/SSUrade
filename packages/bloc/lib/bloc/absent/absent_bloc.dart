import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:ssurade_application/ssurade_application.dart';

part 'absent_event.dart';
part 'absent_state.dart';

class AbsentBloc extends Bloc<AbsentEvent, AbsentState> {
  final AbsentViewModelUseCase _absentViewModelUseCase;
  final SettingViewModelUseCase _settingViewModelUseCase;

  AbsentBloc({
    required AbsentViewModelUseCase absentViewModelUseCase,
    required SettingViewModelUseCase settingViewModelUseCase,
  })  : _absentViewModelUseCase = absentViewModelUseCase,
        _settingViewModelUseCase = settingViewModelUseCase,
        super(AbsentInitial()) {
    on<AbsentReady>((event, emit) async {
      _absentViewModelUseCase.getAbsentManager().then((absentManager) async {
        if (absentManager != null && absentManager != AbsentApplicationManager.empty()) {
          emit(AbsentShowing(absentApplicationManager: absentManager));

          final setting = await _settingViewModelUseCase.getSetting();
          if (setting != null && setting.refreshInformationAutomatically) {
            add(AbsentInformationRefreshRequested());
          }
        } else {
          emit(AbsentInitialLoading());
        }
      });

      return emit.forEach(_absentViewModelUseCase.getAbsentManagerStream(), onData: (data) {
        if (data == AbsentApplicationManager.empty()) {
          return AbsentInitialLoading();
        }

        _absentViewModelUseCase.showToast("유고 결석 정보를 불러왔어요.");
        return AbsentShowing(absentApplicationManager: data);
      });
    });

    on<AbsentInformationRefreshRequested>((event, emit) async {
      _absentViewModelUseCase.showToast("유고 결석 정보를 불러오고 있어요...");

      final result = await _absentViewModelUseCase.loadNewAbsentManager();
      if (!result) {
        addError(Exception('Failed to load new absent manager'), StackTrace.current);
        return;
      }
    });
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    _absentViewModelUseCase.showToast("오류가 발생했어요. ($error)");

    super.onError(error, stackTrace);
  }
}
