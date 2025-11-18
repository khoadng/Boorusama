import 'dart:async';

class LazyAsync<T> {
  LazyAsync(this._factory);

  final Future<T> Function() _factory;
  T? _instance;
  Future<T>? _initializationFuture;
  bool _isInitialized = false;

  FutureOr<T> call() {
    if (_isInitialized) return _instance as T;

    if (_initializationFuture != null) return _initializationFuture!;

    _initializationFuture = _factory()
        .then((value) {
          _instance = value;
          _isInitialized = true;
          return value;
        })
        .catchError((e) {
          _initializationFuture = null;
          throw e;
        });

    return _initializationFuture!;
  }

  bool get isInitialized => _isInitialized;

  void reset() {
    _instance = null;
    _initializationFuture = null;
    _isInitialized = false;
  }
}
