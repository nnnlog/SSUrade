abstract interface class BackgroundProcessUseCase {
  Future<void> fetchGrade();

  Future<void> fetchChapel();

  Future<void> fetchNewChapel();

  Future<void> fetchScholarship();

  Future<void> fetchAbsent();
}
