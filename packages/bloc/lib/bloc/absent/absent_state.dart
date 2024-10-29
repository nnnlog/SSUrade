part of 'absent_bloc.dart';

@immutable
sealed class AbsentState extends Equatable {
  final DateTime lastUpdated = DateTime.now();

  @override
  List<Object?> get props => [lastUpdated];
}

final class AbsentInitial extends AbsentState {
  @override
  List<Object?> get props => super.props + [];
}

final class AbsentInitialLoading extends AbsentState {
  @override
  List<Object?> get props => super.props + [];
}

final class AbsentShowing extends AbsentState {
  final AbsentApplicationManager absentApplicationManager;

  AbsentShowing({
    required this.absentApplicationManager,
  });

  @override
  List<Object?> get props => super.props + [absentApplicationManager];
}
