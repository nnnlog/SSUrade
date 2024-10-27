import 'dart:math';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:ssurade_application/ssurade_application.dart';

part 'grade_event.dart';
part 'grade_state.dart';

part 'grade_bloc.g.dart';

class GradeBloc extends Bloc<GradeEvent, GradeState> {
  final SubjectViewModelUseCase _subjectViewModelUseCase;

  GradeBloc({
    required SubjectViewModelUseCase subjectViewModelUseCase,
  })  : _subjectViewModelUseCase = subjectViewModelUseCase,
        super(GradeInitial()) {
    on<GradeReady>((event, emit) async {
      _subjectViewModelUseCase.getSemesterSubjectsManager().then((value) {
        if (value == null || value.data.length == 0) {
          emit(GradeInitialLoading());
        } else {
          emit(GradeShowing(semesterSubjectsManager: value, showingSemester: value.data.keys.last));
        }
      });

      return emit.forEach(_subjectViewModelUseCase.getSemesterSubjectsManagerStream(), onData: (manager) {
        var state = this.state;
        if (state is! GradeShowing) {
          return GradeShowing(semesterSubjectsManager: manager, showingSemester: manager.data.keys.last);
        } else {
          return GradeShowing(
              semesterSubjectsManager: manager, showingSemester: state.semesterSubjectsManager.data.containsKey(state.showingSemester) ? state.showingSemester : manager.data.keys.last);
        }
      });
    });

    on<GradeYearSemesterSelected>((event, emit) async {
      var state = this.state;
      if (state is! GradeShowing) {
        return;
      }
      emit(state.copyWith(showingSemester: event.yearSemester));
    });

    on<GradeInformationRefreshRequested>((event, emit) async {
      var result = await _subjectViewModelUseCase.loadNewSemesterSubjects(event.yearSemester);
      if (!result) {
        // throw Exception('Failed to load new semester subjects');
        addError(Exception('Failed to load new semester subjects'), StackTrace.current);
        return;
      }
    });

    on<GradeAllInformationRequested>((event, emit) async {
      var result = await _subjectViewModelUseCase.loadNewSemesterSubjectsManager();
      if (!result) {
        // throw Exception('Failed to load new semester subjects manager');
        addError(Exception('Failed to load new semester subjects manager'), StackTrace.current);
        return;
      }
    });

    on<GradeExportSettingChanged>((event, emit) async {
      final state = this.state;

      if (state is! GradeShowing) {
        return;
      }

      emit((state).copyWith(
        isDisplayRankingDuringExporting: event.isDisplayRanking ?? (state).isDisplayRankingDuringExporting,
        isDisplaySubjectInformationDuringExporting: event.isDisplaySubjectInformation ?? (state).isDisplaySubjectInformationDuringExporting,
      ));
    });

    on<GradeExportRequested>((event, emit) async {
      final state = this.state;

      if (state is! GradeShowing) {
        return;
      }

      emit(state.copyWith(isExporting: true));
    });

    on<GradeScreenshotSaveRequested>((event, emit) async {
      final state = this.state;

      if (state is! GradeShowing) {
        return;
      }

      _subjectViewModelUseCase.saveScreenshotInGallery(data: event.data, name: "ssurade_${state.showingSemester.displayText}_${DateTime.now().toLocal().millisecondsSinceEpoch}").then((_) {
        _subjectViewModelUseCase.showToast("이미지를 저장했어요.");
      });

      emit(state.copyWith(isExporting: false));
    });
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    _subjectViewModelUseCase.showToast("오류가 발생했어요. ($error)");
    print(error);

    super.onError(error, stackTrace);
  }
}
