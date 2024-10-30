part of 'app_version_bloc.dart';

@immutable
sealed class AppVersionEvent {}

class AppVersionCheckRequested extends AppVersionEvent {}
