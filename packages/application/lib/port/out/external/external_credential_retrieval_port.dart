abstract interface class ExternalCredentialRetrievalPort {
  Future<List<dynamic>?> getCredential(String id, String password);
}
