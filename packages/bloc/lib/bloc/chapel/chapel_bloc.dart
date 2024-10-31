import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:ssurade_application/ssurade_application.dart';

part 'chapel_bloc.g.dart';
part 'chapel_event.dart';
part 'chapel_state.dart';

class ChapelBloc extends Bloc<ChapelEvent, ChapelState> {
  final ChapelViewModelUseCase _chapelViewModelUseCase;
  final SettingViewModelUseCase _settingViewModelUseCase;

  ChapelBloc({
    required ChapelViewModelUseCase chapelViewModelUseCase,
    required SettingViewModelUseCase settingViewModelUseCase,
  })  : _chapelViewModelUseCase = chapelViewModelUseCase,
        _settingViewModelUseCase = settingViewModelUseCase,
        super(ChapelInitial()) {
    on<ChapelReady>((event, emit) async {
      _chapelViewModelUseCase.getChapelManager().then((value) async {
        if (value == null || value.data.length == 0) {
          emit(ChapelInitialLoading());
        } else {
          emit(ChapelShowing(chapelManager: value, showingYearSemester: value.data.keys.last));

          final setting = await _settingViewModelUseCase.getSetting();
          if (setting != null && setting.refreshInformationAutomatically) {
            add(ChapelInformationRefreshRequested(value.data.keys.last));
          }
        }
      });

      return emit.forEach(_chapelViewModelUseCase.getChapelManagerStream(), onData: (manager) {
        if (manager == ChapelManager.empty()) {
          return ChapelInitial();
        }

        var state = this.state;
        if (state is! ChapelShowing) {
          return ChapelShowing(chapelManager: manager, showingYearSemester: manager.data.keys.last);
        } else {
          _chapelViewModelUseCase.showToast("채플 정보를 불러왔어요.");
          return ChapelShowing(chapelManager: manager, showingYearSemester: state.chapelManager.data.containsKey(state.showingYearSemester) ? state.showingYearSemester : manager.data.keys.last);
        }
      });
    });

    on<ChapelYearSemesterSelected>((event, emit) async {
      var state = this.state;
      if (state is! ChapelShowing) {
        return;
      }

      emit(state.copyWith(showingYearSemester: event.yearSemester));
    });

    on<ChapelOverwrittenAttendanceChanged>((event, emit) async {
      var state = this.state;
      if (state is! ChapelShowing) {
        return;
      }

      var result = await _chapelViewModelUseCase.changeOverwrittenAttendance(state.showingYearSemester, event.attendance, event.newOverwrittenStatus);
      if (!result) {
        // throw Exception('Failed to change overwritten attendance');
        addError(Exception('Failed to change overwritten attendance'), StackTrace.current);
        return;
      }
    });

    on<ChapelInformationRefreshRequested>((event, emit) async {
      _chapelViewModelUseCase.showToast("채플 정보를 불러오고 있어요...");

      var result = await _chapelViewModelUseCase.loadNewChapel(event.yearSemester);
      if (!result) {
        // throw Exception('Failed to load new chapel');
        addError(Exception('Failed to load new chapel'), StackTrace.current);
        return;
      }
    });

    on<ChapelAllInformationRequested>((event, emit) async {
      var result = await _chapelViewModelUseCase.loadNewChapelManager();
      if (!result) {
        // throw Exception('Failed to load new chapel');
        addError(Exception('Failed to load new chapel'), StackTrace.current);
        return;
      }
    });
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    _chapelViewModelUseCase.showToast("오류가 발생했어요. ($error)");
    print(error);
    print(stackTrace);

    super.onError(error, stackTrace);
  }
}
