abstract interface class AgreementRetrievalPort {
  Future<String> getShortAgreement();

  Future<String> getLongAgreement();
}
