part of 'scholarship_bloc.dart';

@immutable
sealed class ScholarshipEvent {}

class ScholarshipReady extends ScholarshipEvent {}

class ScholarshipInformationRefreshRequested extends ScholarshipEvent {}
