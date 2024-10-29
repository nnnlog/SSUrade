part of 'absent_bloc.dart';

@immutable
sealed class AbsentEvent {}

class AbsentReady extends AbsentEvent {}

class AbsentInformationRefreshRequested extends AbsentEvent {}
