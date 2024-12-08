const String _basePath = '/storage/emulated';
const String _sdCardBasePath = '/storage';

const List<String> _allowedDownloadFolders = [
  'Download',
  // 'Downloads',
  'Documents',
  'Pictures',
];

bool isInternalStorage(String? path) => path?.startsWith(_basePath) ?? false;

bool isUserspaceInternalStorage(String? path) {
  if (path == null) return false;
  if (!isInternalStorage(path)) return false;

  final folders = path.split('/');

  if (folders.length < 4) return false;

  // check if this is on the user space
  return int.tryParse(folders[3]) != null;
}

bool isSdCardStorage(String? path) {
  if (path == null) return false;

  final folders = path.split('/');

  if (folders.length < 3) return false;

  // not emulated storage
  return folders[2] != 'emulated';
}

bool isSdCardPublicDirectories(String? path) {
  if (path == null) return false;
  if (!isSdCardStorage(path)) return false;

  final nonBasePath = path.replaceAll('$_sdCardBasePath/', '');
  final paths = nonBasePath.split('/');

  if (paths.length < 2) return false;

  final selectedFolder = paths[1];

  return _allowedDownloadFolders.contains(selectedFolder);
}

bool isPublicDirectories(String? path) {
  try {
    if (path == null) return false;
    if (!isUserspaceInternalStorage(path)) return false;

    final nonBasePath = path.replaceAll('$_basePath/', '');
    final paths = nonBasePath.split('/');

    if (paths.length < 2) return false;

    final selectedFolder = paths[1];

    return _allowedDownloadFolders.contains(selectedFolder);
  } catch (e) {
    return false;
  }
}

mixin DownloadPathValidatorMixin {
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
      (hasScopeStorage
          ? (isPublicDirectories(storagePath) ||
              isSdCardPublicDirectories(storagePath))
          : true);
}
