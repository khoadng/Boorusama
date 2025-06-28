enum DownloadFilter {
  pending,
  paused,
  inProgress,
  completed,
  canceled,
  failed,
}

DownloadFilter convertFilter(String? filter) => switch (filter) {
      'error' => DownloadFilter.failed,
      'running' => DownloadFilter.inProgress,
      _ => DownloadFilter.completed,
    };

extension DownloadFilterLocalize on DownloadFilter? {
  String localize() => switch (this) {
        DownloadFilter.pending => 'Pending',
        DownloadFilter.paused => 'Paused',
        DownloadFilter.inProgress => 'In Progress',
        DownloadFilter.completed => 'Completed',
        DownloadFilter.canceled => 'Canceled',
        DownloadFilter.failed => 'Failed',
        null => 'Unknown',
      };

  String emptyLocalize() => switch (this) {
        DownloadFilter.pending => 'No pending downloads',
        DownloadFilter.paused => 'No paused downloads',
        DownloadFilter.inProgress => 'No downloads in progress',
        DownloadFilter.completed => 'No completed downloads',
        DownloadFilter.canceled => 'No canceled downloads',
        DownloadFilter.failed => 'No failed downloads',
        null => 'No downloads',
      };
}
