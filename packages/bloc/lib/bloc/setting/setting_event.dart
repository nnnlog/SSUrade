part of 'setting_bloc.dart';

@immutable
sealed class SettingEvent {}

class SettingReady extends SettingEvent {}

class SettingChanged extends SettingEvent {
  final Setting setting;

  SettingChanged(this.setting);
}

class SettingToastMessageRequested extends SettingEvent {
  final String message;

  SettingToastMessageRequested(this.message);
}

enum SettingJobType {
  loadGradeInformation,
  removeGradeInformation,
  loadChapelInformation,
  removeChapelInformation,
  loadAbsentInformation,
  removeAbsentInformation,
  loadScholarshipInformation,
  removeScholarshipInformation,
  validateCredential,
  logout,
}

class SettingJobRequested extends SettingEvent {
  final SettingJobType jobType;

  SettingJobRequested(this.jobType);
}
