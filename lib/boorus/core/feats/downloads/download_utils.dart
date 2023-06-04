const String _basePath = '/storage/emulated/0';
const List<String> _allowedDownloadFolders = [
  'Download',
  'Downloads',
  'Documents',
  'Pictures',
];

bool isInternalStorage(String? path) => path?.startsWith(_basePath) ?? false;

bool isNonPublicDirectories(String? path) {
  try {
    if (path == null) return false;
    if (!isInternalStorage(path)) return false;

    final nonBasePath = path.replaceAll('$_basePath/', '');
    final paths = nonBasePath.split('/');

    return paths.isEmpty || !_allowedDownloadFolders.contains(paths.first);
  } catch (e) {
    return false;
  }
}

mixin DownloadMixin {
  String? get storagePath;

  bool shouldDisplayWarning({
    required bool hasScopeStorage,
  }) =>
      storagePath != null &&
      storagePath!.isNotEmpty &&
      !hasValidStoragePath(hasScopeStorage: hasScopeStorage);

  bool isValidDownload({
    required bool hasScopeStorage,
  }) =>
      storagePath != null &&
      storagePath!.isNotEmpty &&
      hasValidStoragePath(hasScopeStorage: hasScopeStorage);

  List<String> get allowedFolders => _allowedDownloadFolders;

  /// Checks if the [storagePath] is valid for storing downloaded files.
  ///
  /// A valid storage path must:
  /// - not be null or empty
  /// - be an internal storage path
  /// - not contain non-public directories if [hasScopeStorage] is true
  ///
  /// @param [hasScopeStorage] whether the storage path should have scope storage
  /// @return true if the storage path is valid, false otherwise
  bool hasValidStoragePath({
    required bool hasScopeStorage,
  }) =>
      storagePath != null &&
      storagePath!.isNotEmpty &&
      isInternalStorage(storagePath) &&
      (hasScopeStorage ? !isNonPublicDirectories(storagePath) : true);
}
