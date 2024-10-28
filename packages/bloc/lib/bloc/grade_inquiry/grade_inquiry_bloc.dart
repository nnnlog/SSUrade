import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:ssurade_application/domain/model/subject/semester_subjects_manager.dart';
import 'package:ssurade_application/port/in/viewmodel/subject_view_model_use_case.dart';

part 'grade_inquiry_event.dart';
part 'grade_inquiry_state.dart';

class GradeInquiryBloc extends Bloc<GradeInquiryEvent, GradeInquiryState> {
  final SubjectViewModelUseCase _subjectViewModelUseCase;

  GradeInquiryBloc({
    required SubjectViewModelUseCase subjectViewModelUseCase,
  })  : this._subjectViewModelUseCase = subjectViewModelUseCase,
        super(GradeInquiryInitial()) {
    on<GradeInquiryReady>((event, emit) async {
      var semesterSubjectsManager = await _subjectViewModelUseCase.getSemesterSubjectsManager();
      if (semesterSubjectsManager == null) {
        emit(GradeInquiryEmpty());
      } else {
        emit(GradeInquiryShowing(semesterSubjectsManager));
      }

      return emit.forEach(_subjectViewModelUseCase.getSemesterSubjectsManagerStream(), onData: (data) {
        return GradeInquiryShowing(data);
      });
    });

    on<GradeInquiryUpdated>((event, emit) {
      emit(GradeInquiryShowing(event.semesterSubjectsManager));
    });
  }

  @override
  void onChange(Change<GradeInquiryState> change) {
    if (change.nextState is GradeInquiryEmpty) {
      _subjectViewModelUseCase.showToast("성적 정보가 없습니다.\n'학기별 성적 조회'에서 성적을 먼저 조회해주세요.");
    }

    super.onChange(change);
  }
}
