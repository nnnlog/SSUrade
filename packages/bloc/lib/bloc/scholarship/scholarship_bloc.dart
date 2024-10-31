import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:ssurade_application/ssurade_application.dart';

part 'scholarship_event.dart';
part 'scholarship_state.dart';

class ScholarshipBloc extends Bloc<ScholarshipEvent, ScholarshipState> {
  final ScholarshipViewModelUseCase _scholarshipViewModelUseCase;
  final SettingViewModelUseCase _settingViewModelUseCase;

  ScholarshipBloc({
    required ScholarshipViewModelUseCase scholarshipViewModelUseCase,
    required SettingViewModelUseCase settingViewModelUseCase,
  })  : _scholarshipViewModelUseCase = scholarshipViewModelUseCase,
        _settingViewModelUseCase = settingViewModelUseCase,
        super(ScholarshipInitial()) {
    on<ScholarshipReady>((event, emit) async {
      _scholarshipViewModelUseCase.getScholarshipManager().then((scholarshipManager) async {
        if (scholarshipManager != null) {
          emit(ScholarshipShowing(scholarshipManager: scholarshipManager));

          var setting = await _settingViewModelUseCase.getSetting();
          if (setting != null && setting.refreshInformationAutomatically) {
            add(ScholarshipInformationRefreshRequested());
          }
        } else {
          emit(ScholarshipInitialLoading());
        }
      });

      return emit.forEach(_scholarshipViewModelUseCase.getScholarshipManagerStream(), onData: (data) {
        if (data == ScholarshipManager.empty()) {
          return ScholarshipInitialLoading();
        }

        _scholarshipViewModelUseCase.showToast("장학금 정보를 불러왔어요.");
        return ScholarshipShowing(scholarshipManager: data);
      });
    });

    on<ScholarshipInformationRefreshRequested>((event, emit) async {
      _scholarshipViewModelUseCase.showToast("장학금 정보를 불러오고 있어요...");

      final result = await _scholarshipViewModelUseCase.loadNewScholarshipManager();
      if (!result) {
        addError(Exception('Failed to load new scholarship manager'), StackTrace.current);
        return;
      }
    });
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    _scholarshipViewModelUseCase.showToast("오류가 발생했어요. ($error)");

    super.onError(error, stackTrace);
  }
}
