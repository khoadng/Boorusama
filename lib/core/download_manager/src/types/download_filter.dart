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

const kFilterOptions = [
  DownloadFilter.inProgress,
  DownloadFilter.pending,
  DownloadFilter.paused,
  DownloadFilter.completed,
  DownloadFilter.failed,
  DownloadFilter.canceled,
];
