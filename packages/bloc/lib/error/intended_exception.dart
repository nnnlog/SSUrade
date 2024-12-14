class IntendedException {
  final String message;
  final bool goToBack;

  IntendedException({
    required this.message,
    this.goToBack = false,
  });

  @override
  String toString() {
    return message;
  }
}
