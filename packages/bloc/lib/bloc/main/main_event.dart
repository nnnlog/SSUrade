part of 'main_bloc.dart';

@immutable
sealed class MainEvent {}

class MainReady extends MainEvent {}

class MainAgreeEvent extends MainEvent {}

class MainDisagreeEvent extends MainEvent {}
