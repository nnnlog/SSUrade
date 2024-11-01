abstract interface class MainViewModelUseCase {
  Future<String> getAgreementShort();

  Future<String> getAgreement();

  Future<void> showToast(String message);

  void exitApp();
}
