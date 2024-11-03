import 'dart:async';

class ParallelWorker<T, E> {
  final List<Future<T> Function(E)> _jobs;
  final Set<E> _workers;
  final Completer<List<T>> _completer = Completer<List<T>>();
  final List<T> _result = [];

  ParallelWorker({
    required List<Future<T> Function(E)> jobs,
    required List<E> workers,
  })  : _jobs = List.from(jobs),
        _workers = Set.from(workers) {
    _start();
  }

  Future<List<T>> get result => _completer.future;

  void _run(E worker) {
    if (_jobs.isEmpty) {
      _workers.remove(worker);
      if (_workers.isEmpty) {
        _completer.complete(_result);
      }
      return;
    }

    final job = _jobs.removeLast();

    job(worker).then((value) {
      _result.add(value);
      _run(worker);
    }).catchError((error) {
      _completer.completeError(error);
    });
  }

  void _start() {
    _workers.toList().forEach((worker) {
      _run(worker);
    }); // copy to list to avoid concurrent modification
  }
}
