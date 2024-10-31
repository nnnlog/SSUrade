part of 'setting_bloc.dart';

@immutable
sealed class SettingState extends Equatable {
  final DateTime lastUpdated = DateTime.now();

  @override
  List<Object?> get props => [lastUpdated];
}

final class SettingInitial extends SettingState {
  @override
  List<Object?> get props => super.props + [];
}

@CopyWith()
final class SettingShowing extends SettingState {
  final Setting setting;
  final bool isLogined;

  SettingShowing(this.setting, this.isLogined);

  @override
  List<Object?> get props => super.props + [setting, isLogined];
}
