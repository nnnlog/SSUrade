part of 'chapel_bloc.dart';

@immutable
sealed class ChapelEvent {}

class ChapelReady extends ChapelEvent {}

class ChapelYearSemesterSelected extends ChapelEvent {
  final YearSemester yearSemester;

  ChapelYearSemesterSelected(this.yearSemester);
}

class ChapelOverwrittenAttendanceChanged extends ChapelEvent {
  final ChapelAttendance attendance;
  final ChapelAttendanceStatus newOverwrittenStatus;

  ChapelOverwrittenAttendanceChanged(this.attendance, this.newOverwrittenStatus);
}

class ChapelInformationRefreshRequested extends ChapelEvent {
  final YearSemester yearSemester;

  ChapelInformationRefreshRequested(this.yearSemester);
}

class ChapelAllInformationRequested extends ChapelEvent {}

class ChapelGoToBackRequested extends ChapelEvent {}
