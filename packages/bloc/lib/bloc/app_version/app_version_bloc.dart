import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:ssurade_application/ssurade_application.dart';

part 'app_version_event.dart';
part 'app_version_state.dart';

class AppVersionBloc extends Bloc<AppVersionEvent, AppVersionState> {
  final AppVersionViewModelUseCase _appVersionViewModelUseCase;

  AppVersionBloc({
    required AppVersionViewModelUseCase appVersionViewModelUseCase,
  })  : _appVersionViewModelUseCase = appVersionViewModelUseCase,
        super(AppVersionInitial()) {
    on<AppVersionCheckRequested>((event, emit) async {
      emit(AppVersionLoading());
      final appVersion = await _appVersionViewModelUseCase.getAppVersion();
      if (appVersion == null) {
        addError(Exception("Failed to load app version."));
        return;
      }
      emit(AppVersionShowing(appVersion));
    });
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
  }
}
