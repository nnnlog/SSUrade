import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:ssurade_application/ssurade_application.dart';

part 'setting_bloc.g.dart';
part 'setting_event.dart';
part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final SettingViewModelUseCase _settingViewModelUseCase;
  final AbsentViewModelUseCase _absentViewModelUseCase;
  final ChapelViewModelUseCase _chapelViewModelUseCase;
  final SubjectViewModelUseCase _subjectViewModelUseCase;
  final LoginViewModelUseCase _loginViewModelUseCase;
  final ScholarshipViewModelUseCase _scholarshipViewModelUseCase;

  SettingBloc({
    required SettingViewModelUseCase settingViewModelUseCase,
    required AbsentViewModelUseCase absentViewModelUseCase,
    required ChapelViewModelUseCase chapelViewModelUseCase,
    required SubjectViewModelUseCase subjectViewModelUseCase,
    required LoginViewModelUseCase loginViewModelUseCase,
    required ScholarshipViewModelUseCase scholarshipViewModelUseCase,
  })  : _settingViewModelUseCase = settingViewModelUseCase,
        _absentViewModelUseCase = absentViewModelUseCase,
        _chapelViewModelUseCase = chapelViewModelUseCase,
        _subjectViewModelUseCase = subjectViewModelUseCase,
        _loginViewModelUseCase = loginViewModelUseCase,
        _scholarshipViewModelUseCase = scholarshipViewModelUseCase,
        super(SettingInitial()) {
    on<SettingReady>((event, emit) async {
      _settingViewModelUseCase.getSetting().then((setting) async {
        if (setting == null) {
          _settingViewModelUseCase.applyNewSetting(Setting.defaults());
        } else {
          final credential = await _loginViewModelUseCase.getCredential();
          emit(SettingShowing(setting, credential != null && credential != Credential.empty()));
        }
      });

      return (() async {
        await Future.wait([
          emit.forEach(settingViewModelUseCase.getSettingStream(), onData: (setting) {
            var state = this.state;
            if (state is SettingShowing) {
              return SettingShowing(setting, state.isLogined);
            }
            return SettingInitial();
          }),
          emit.forEach(_loginViewModelUseCase.getCredentialStream(), onData: (credential) {
            var state = this.state;
            if (state is SettingShowing) {
              return SettingShowing(state.setting, credential != Credential.empty());
            }
            return SettingInitial();
          })
        ]);
      })();
    });

    on<SettingChanged>((event, emit) async {
      var state = this.state;
      if (state is! SettingShowing) {
        return;
      }

      _settingViewModelUseCase.applyNewSetting(event.setting);
      emit(state.copyWith(setting: event.setting));
    });

    on<SettingJobRequested>((event, emit) async {
      switch (event.jobType) {
        case SettingJobType.loadGradeInformation:
          var result = await _subjectViewModelUseCase.loadNewSemesterSubjectsManager();
          if (result) {
            _settingViewModelUseCase.showToast("성적 정보를 불러왔어요.");
          } else {
            _settingViewModelUseCase.showToast("성적 정보를 불러오지 못했어요.");
          }
          break;
        case SettingJobType.removeGradeInformation:
          await _subjectViewModelUseCase.clearSemesterSubjectsManager();
          _settingViewModelUseCase.showToast("성적 정보를 삭제했어요.");
          break;
        case SettingJobType.loadChapelInformation:
          var result = await _chapelViewModelUseCase.loadNewChapelManager();
          if (result) {
            _settingViewModelUseCase.showToast("채플 정보를 불러왔어요.");
          } else {
            _settingViewModelUseCase.showToast("채플 정보를 불러오지 못했어요.");
          }
          break;
        case SettingJobType.removeChapelInformation:
          await _chapelViewModelUseCase.clearChapelManager();
          _settingViewModelUseCase.showToast("채플 정보를 삭제했어요.");
          break;
        case SettingJobType.loadAbsentInformation:
          var result = await _absentViewModelUseCase.loadNewAbsentManager();
          if (result) {
            _settingViewModelUseCase.showToast("결석 정보를 불러왔어요.");
          } else {
            _settingViewModelUseCase.showToast("결석 정보를 불러오지 못했어요.");
          }
          break;
        case SettingJobType.removeAbsentInformation:
          await _absentViewModelUseCase.clearAbsentManager();
          _settingViewModelUseCase.showToast("결석 정보를 삭제했어요.");
          break;
        case SettingJobType.loadScholarshipInformation:
          var result = await _scholarshipViewModelUseCase.loadNewScholarshipManager();
          if (result) {
            _settingViewModelUseCase.showToast("장학 정보를 불러왔어요.");
          } else {
            _settingViewModelUseCase.showToast("장학 정보를 불러오지 못했어요.");
          }
          break;
        case SettingJobType.removeScholarshipInformation:
          await _scholarshipViewModelUseCase.clearScholarshipManager();
          _settingViewModelUseCase.showToast("장학 정보를 삭제했어요.");
          break;
        case SettingJobType.validateCredential:
          final credential = await _loginViewModelUseCase.getCredential();
          if (credential != null) {
            final isValid = await _loginViewModelUseCase.validateCredential(credential);
            _settingViewModelUseCase.showToast(isValid ? "로그인할 수 있는 정보에요." : "로그인할 수 없는 정보에요. (네트워크 문제 등 일시적으로 발생하는 문제일 수 있어요.)");
          }
          break;
        case SettingJobType.logout:
          await Future.wait([
            _loginViewModelUseCase.clearCredential(),
            _subjectViewModelUseCase.clearSemesterSubjectsManager(),
            _chapelViewModelUseCase.clearChapelManager(),
            _absentViewModelUseCase.clearAbsentManager(),
            _scholarshipViewModelUseCase.clearScholarshipManager(),
          ]);

          _settingViewModelUseCase.showToast("로그아웃했어요.");
          break;
      }
    });
  }
}
