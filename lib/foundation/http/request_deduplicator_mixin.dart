mixin RequestDeduplicator<T> {
  final _ongoingRequests = <String, Future<T>>{};

  /// Deduplicates a request based on a unique [key].
  ///
  /// If there is an ongoing request with the same [key], this method will return
  /// the ongoing request instead of creating a new one.
  ///
  /// If there is no ongoing request with the same [key], this method will create
  /// a new request by calling the [request] function .
  ///
  /// When the request is completed, the corresponding entry will be removed.
  ///
  /// Returns the ongoing request if there is one, or the new request created by
  /// calling [request].
  Future<T> deduplicate(String key, Future<T> Function() request) {
    if (_ongoingRequests.containsKey(key)) {
      return _ongoingRequests[key]!;
    }

    _ongoingRequests[key] = request().whenComplete(() {
      _ongoingRequests.remove(key);
    });

    return _ongoingRequests[key]!;
  }
}
