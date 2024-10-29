part of 'scholarship_bloc.dart';

@immutable
sealed class ScholarshipState extends Equatable {
  final DateTime lastUpdated = DateTime.now();

  @override
  List<Object?> get props => [lastUpdated];
}

final class ScholarshipInitial extends ScholarshipState {
  @override
  List<Object?> get props => super.props + [];
}

final class ScholarshipInitialLoading extends ScholarshipState {
  @override
  List<Object?> get props => super.props + [];
}

final class ScholarshipShowing extends ScholarshipState {
  final ScholarshipManager scholarshipManager;

  ScholarshipShowing({
    required this.scholarshipManager,
  });

  @override
  List<Object?> get props => super.props + [scholarshipManager];
}
