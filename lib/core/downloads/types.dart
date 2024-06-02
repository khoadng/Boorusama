typedef DownloadFilenameBuilder = String Function();

enum DownloadFilter {
  all,
  pending,
  paused,
  inProgress,
  completed,
  failed,
}
