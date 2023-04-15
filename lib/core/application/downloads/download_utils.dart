const String _basePath = '/storage/emulated/0';
const List<String> _allowedDownloadFolders = [
  'Download',
  'Downloads',
  'Documents',
  'Pictures',
];

bool isInternalStorage(String? path) {
  if (path == null) return false;

  return path.startsWith(_basePath);
}

bool isNonPublicDirectories(String? path) {
  try {
    if (path == null) return false;
    if (!isInternalStorage(path)) return false;

    final nonBasePath = path.replaceAll('$_basePath/', '');
    final paths = nonBasePath.split('/');

    if (paths.isEmpty) return true;
    if (!_allowedDownloadFolders.contains(paths.first)) return true;

    return false;
  } catch (e) {
    return false;
  }
}

mixin DownloadMixin {
  String get storagePath;

  bool shouldDisplayWarning({
    required bool hasScopeStorage,
  }) {
    if (storagePath.isEmpty) return false;

    return !hasValidStoragePath(hasScopeStorage: hasScopeStorage);
  }

  bool isValidDownload({
    required bool hasScopeStorage,
  }) =>
      storagePath.isNotEmpty &&
      hasValidStoragePath(hasScopeStorage: hasScopeStorage);

  List<String> get allowedFolders => _allowedDownloadFolders;

  bool hasValidStoragePath({
    required bool hasScopeStorage,
  }) {
    if (storagePath.isEmpty) return false;
    if (!isInternalStorage(storagePath)) return false;

    // ignore: avoid_bool_literals_in_conditional_expressions
    return hasScopeStorage ? !isNonPublicDirectories(storagePath) : true;
  }
}
