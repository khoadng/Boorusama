// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:oktoast/oktoast.dart';

// Project imports:
import 'package:boorusama/foundation/theme/theme.dart';

const String _basePath = '/storage/emulated';

const List<String> _allowedDownloadFolders = [
  'Download',
  'Downloads',
  'Documents',
  'Pictures',
];

const kBoorusamaCustomDownloadFileNameFormat =
    '{character:nomod,delimiter=comma ,limit=5} ({copyright:nomod,limit=3}) drawn by {artist} - {md5}.{extension}';

const kBoorusamaBulkDownloadCustomFileNameFormat =
    '{index}_{md5:maxlength=8}.{extension}';

bool isInternalStorage(String? path) => path?.startsWith(_basePath) ?? false;

bool isUserspaceInternalStorage(String? path) {
  if (path == null) return false;
  if (!isInternalStorage(path)) return false;

  final folders = path.split('/');

  if (folders.length < 4) return false;

  // check if this is on the user space
  return int.tryParse(folders[3]) != null;
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
      isUserspaceInternalStorage(storagePath) &&
      (hasScopeStorage ? isPublicDirectories(storagePath) : true);
}

void showDownloadStartToast(BuildContext context) {
  showToast(
    'Download started',
    context: context,
    position: const ToastPosition(
      align: Alignment.bottomCenter,
    ),
    textPadding: const EdgeInsets.all(12),
    textStyle: TextStyle(color: context.colorScheme.surface),
    backgroundColor: context.colorScheme.onBackground,
  );
}
