final class LazyManaged<T> {
  LazyManaged({
    required Future<T> Function() create,
    required Future<void> Function(T value) dispose,
  }) : _create = create,
       _dispose = dispose;

  final Future<T> Function() _create;
  final Future<void> Function(T value) _dispose;
  Future<T>? _resourceFuture;
  Future<void>? _closeFuture;
  var _isClosed = false;

  Future<T> get() {
    if (_isClosed) {
      throw StateError('LazyManaged has already been closed');
    }

    return _resourceFuture ??= _create();
  }

  Future<void> close() => _closeFuture ??= _closeInternal();

  Future<void> _closeInternal() async {
    _isClosed = true;
    final resourceFuture = _resourceFuture;
    if (resourceFuture == null) return;

    await _dispose(await resourceFuture);
  }
}
