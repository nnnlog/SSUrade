part of 'app_version_bloc.dart';

@immutable
sealed class AppVersionState extends Equatable {
  final DateTime lastUpdated = DateTime.now();

  @override
  List<Object> get props => [lastUpdated];
}

final class AppVersionInitial extends AppVersionState {
  @override
  List<Object> get props => super.props + [];
}

final class AppVersionLoading extends AppVersionState {
  @override
  List<Object> get props => super.props + [];
}

final class AppVersionShowing extends AppVersionState {
  final AppVersion version;

  AppVersionShowing(this.version);

  @override
  List<Object> get props => super.props + [version];
}
