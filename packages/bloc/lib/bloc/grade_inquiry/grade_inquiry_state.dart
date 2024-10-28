part of 'grade_inquiry_bloc.dart';

@immutable
sealed class GradeInquiryState extends Equatable {}

final class GradeInquiryInitial extends GradeInquiryState {
  @override
  List<Object?> get props => [];
}

final class GradeInquiryEmpty extends GradeInquiryState {
  @override
  List<Object?> get props => [];
}

final class GradeInquiryShowing extends GradeInquiryState {
  final SemesterSubjectsManager semesterSubjectsManager;

  GradeInquiryShowing(this.semesterSubjectsManager);

  @override
  List<Object?> get props => [semesterSubjectsManager];
}
