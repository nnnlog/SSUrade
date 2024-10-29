import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:ssurade_application/ssurade_application.dart';

part 'absent_event.dart';
part 'absent_state.dart';

class AbsentBloc extends Bloc<AbsentEvent, AbsentState> {
  final AbsentViewModelUseCase _absentViewModelUseCase;

  AbsentBloc({
    required AbsentViewModelUseCase absentViewModelUseCase,
  })  : _absentViewModelUseCase = absentViewModelUseCase,
        super(AbsentInitial()) {
    on<AbsentReady>((event, emit) async {
      final absentManager = await _absentViewModelUseCase.getAbsentManager();
      if (absentManager != null) {
        emit(AbsentShowing(absentApplicationManager: absentManager));
      } else {
        emit(AbsentInitialLoading());
      }

      return emit.forEach(_absentViewModelUseCase.getAbsentManagerStream(), onData: (data) {
        if (data == AbsentApplicationManager.empty()) {
          return AbsentInitialLoading();
        }
        return AbsentShowing(absentApplicationManager: data);
      });
    });

    on<AbsentInformationRefreshRequested>((event, emit) async {
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
