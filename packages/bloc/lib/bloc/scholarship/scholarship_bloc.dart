import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:ssurade_application/ssurade_application.dart';

part 'scholarship_event.dart';
part 'scholarship_state.dart';

class ScholarshipBloc extends Bloc<ScholarshipEvent, ScholarshipState> {
  final ScholarshipViewModelUseCase _scholarshipViewModelUseCase;

  ScholarshipBloc({
    required ScholarshipViewModelUseCase scholarshipViewModelUseCase,
  })  : _scholarshipViewModelUseCase = scholarshipViewModelUseCase,
        super(ScholarshipInitial()) {
    on<ScholarshipReady>((event, emit) async {
      final scholarshipManager = await _scholarshipViewModelUseCase.getScholarshipManager();
      if (scholarshipManager != null) {
        emit(ScholarshipShowing(scholarshipManager: scholarshipManager));
      } else {
        emit(ScholarshipInitialLoading());
      }

      return emit.forEach(_scholarshipViewModelUseCase.getScholarshipManagerStream(), onData: (data) {
        if (data == ScholarshipManager.empty) {
          return ScholarshipInitialLoading();
        }
        return ScholarshipShowing(scholarshipManager: data);
      });
    });

    on<ScholarshipInformationRefreshRequested>((event, emit) async {
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
