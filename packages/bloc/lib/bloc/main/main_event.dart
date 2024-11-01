part of 'main_bloc.dart';

@immutable
sealed class MainEvent {}

class MainReady extends MainEvent {}
