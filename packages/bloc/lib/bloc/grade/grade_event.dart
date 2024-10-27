part of 'grade_bloc.dart';

@immutable
sealed class GradeEvent {}

class GradeReady extends GradeEvent {}

class GradeYearSemesterSelected extends GradeEvent {
  final YearSemester yearSemester;

  GradeYearSemesterSelected(this.yearSemester);
}

class GradeInformationRefreshRequested extends GradeEvent {
  final YearSemester yearSemester;

  GradeInformationRefreshRequested(this.yearSemester);
}

class GradeAllInformationRequested extends GradeEvent {}

class GradeExportSettingChanged extends GradeEvent {
  final bool? isDisplayRanking;
  final bool? isDisplaySubjectInformation;

  GradeExportSettingChanged({this.isDisplayRanking = null, this.isDisplaySubjectInformation = null});
}

class GradeExportRequested extends GradeEvent {
  GradeExportRequested();
}

class GradeScreenshotSaveRequested extends GradeEvent {
  final Uint8List data;

  GradeScreenshotSaveRequested(this.data);
}
