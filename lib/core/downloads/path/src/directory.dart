// Project imports:
import '../../../../foundation/filesystem.dart';

sealed class DownloadDirectoryResult {
  const DownloadDirectoryResult();
}

final class DownloadDirectorySuccess extends DownloadDirectoryResult {
  const DownloadDirectorySuccess(this.path);

  final String path;
}

final class DownloadDirectoryFailure extends DownloadDirectoryResult {
  const DownloadDirectoryFailure([this.message]);

  final String? message;
}

Future<DownloadDirectoryResult> tryGetDownloadDirectory(
  AppFileSystem fs,
) async {
  final path = await fs.getDownloadPath();
  if (path == null) {
    return const DownloadDirectoryFailure('Download directory not available');
  }
  return DownloadDirectorySuccess(path);
}

Future<DownloadDirectoryResult> tryGetCustomDownloadDirectory(
  AppFileSystem fs,
  String path,
) async {
  try {
    if (!fs.directoryExistsSync(path)) {
      return const DownloadDirectoryFailure('Directory not found');
    }
    return DownloadDirectorySuccess(path);
  } catch (e) {
    return DownloadDirectoryFailure(e.toString());
  }
}
