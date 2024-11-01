import 'package:injectable/injectable.dart';
import 'package:ssurade_application/port/in/viewmodel/main_view_model_use_case.dart';
import 'package:ssurade_application/port/out/application/agreement_retrieval_port.dart';
import 'package:ssurade_application/port/out/application/exit_app_port.dart';
import 'package:ssurade_application/port/out/application/toast_port.dart';

@Singleton(as: MainViewModelUseCase)
class MainViewModelService implements MainViewModelUseCase {
  final AgreementRetrievalPort _agreementRetrievalPort;
  final ToastPort _toastPort;
  final ExitAppPort _exitAppPort;

  MainViewModelService({
    required AgreementRetrievalPort agreementRetrievalPort,
    required ToastPort toastPort,
    required ExitAppPort exitAppPort,
  })  : _agreementRetrievalPort = agreementRetrievalPort,
        _toastPort = toastPort,
        _exitAppPort = exitAppPort;

  @override
  Future<String> getAgreement() {
    return _agreementRetrievalPort.getLongAgreement();
  }

  @override
  Future<String> getAgreementShort() {
    return _agreementRetrievalPort.getShortAgreement();
  }

  @override
  Future<void> showToast(String message) {
    return _toastPort.showToast(message);
  }

  @override
  void exitApp() {
    _exitAppPort.exitApp();
  }
}
