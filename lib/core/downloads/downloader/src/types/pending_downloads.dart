final class PendingDownloads {
  PendingDownloads({
    required bool Function(String url) isActive,
  }) : _isActive = isActive;

  final bool Function(String url) _isActive;
  final _claimed = <String>{};

  bool claim(String url) => !_isActive(url) && _claimed.add(url);

  void release(String url) => _claimed.remove(url);
}
