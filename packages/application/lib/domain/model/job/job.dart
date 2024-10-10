abstract class Job<T> {
  void cancel();

  bool get finished;

  Future<T> get result;
}
