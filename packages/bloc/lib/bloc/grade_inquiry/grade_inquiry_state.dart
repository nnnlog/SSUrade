part of 'grade_inquiry_bloc.dart';

@immutable
sealed class GradeInquiryState extends Equatable {
  final DateTime lastUpdated = DateTime.now();

  @override
  List<Object?> get props => [lastUpdated];
}

final class GradeInquiryInitial extends GradeInquiryState {
  @override
  List<Object?> get props => super.props + [];
}

final class GradeInquiryEmpty extends GradeInquiryState {
  @override
  List<Object?> get props => super.props + [];
}

final class GradeInquiryShowing extends GradeInquiryState {
  final SemesterSubjectsManager semesterSubjectsManager;

  GradeInquiryShowing(this.semesterSubjectsManager);

  @override
  List<Object?> get props => super.props + [semesterSubjectsManager];
}
