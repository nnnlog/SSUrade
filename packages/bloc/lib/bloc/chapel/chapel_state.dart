part of 'chapel_bloc.dart';

@immutable
sealed class ChapelState extends Equatable {
  final DateTime lastUpdated = DateTime.now();

  @override
  List<Object?> get props => [lastUpdated];
}

final class ChapelInitial extends ChapelState {
  @override
  List<Object?> get props => super.props + [];
}

final class ChapelInitialLoading extends ChapelState {
  @override
  List<Object?> get props => super.props + [];
}

@CopyWith()
final class ChapelShowing extends ChapelState {
  final ChapelManager chapelManager;
  final YearSemester showingYearSemester;

  ChapelShowing({
    required this.chapelManager,
    required this.showingYearSemester,
  });

  Chapel get showingChapel => chapelManager.data[showingYearSemester]!;

  @override
  List<Object?> get props => super.props + [chapelManager, showingYearSemester];
}
