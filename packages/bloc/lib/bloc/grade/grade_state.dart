part of 'grade_bloc.dart';

@immutable
sealed class GradeState extends Equatable {
  final DateTime lastUpdated = DateTime.now();

  @override
  List<Object?> get props => [lastUpdated];
}

final class GradeInitial extends GradeState {
  @override
  List<Object?> get props => super.props + [];
}

final class GradeInitialLoading extends GradeState {
  @override
  List<Object?> get props => super.props + [];
}

@CopyWith()
final class GradeShowing extends GradeState {
  final SemesterSubjectsManager semesterSubjectsManager;
  final YearSemester showingSemester;

  final bool isExporting;
  final bool isDisplayRankingDuringExporting;
  final bool isDisplaySubjectInformationDuringExporting;

  GradeShowing({
    required this.semesterSubjectsManager,
    required this.showingSemester,
    this.isExporting = false,
    this.isDisplayRankingDuringExporting = true,
    this.isDisplaySubjectInformationDuringExporting = true,
  });

  @override
  List<Object?> get props => super.props + [semesterSubjectsManager, showingSemester, isExporting, isDisplayRankingDuringExporting, isDisplaySubjectInformationDuringExporting];
}
