part of 'grade_inquiry_bloc.dart';

@immutable
sealed class GradeInquiryEvent {}

class GradeInquiryReady extends GradeInquiryEvent {}

class GradeInquiryUpdated extends GradeInquiryEvent {
  final SemesterSubjectsManager semesterSubjectsManager;

  GradeInquiryUpdated(this.semesterSubjectsManager);
}
