class DownloadTranslations {
  const DownloadTranslations._();

  static const String downloadManagerTitle = 'Downloads';

  static const String retryAllFailed = 'Retry all';

  static const String downloadFailedNotification = 'failed';
  static const String downloadCompletedNotification = 'completed';
  static const String downloadStartedNotification = 'Download started';
  static const String downloadNothingToClear = 'Nothing to clear';

  static const String downloadPath = 'settings.download.path';
  static const String downloadSelectFolder =
      'settings.download.select_a_folder';
  static const String downloadSelectFolderWarning =
      'download.bulk_download_folder_select_warning';

  static const String skipDownloadIfExists = 'Skip existing files';
  static const String skipDownloadIfExistsExplanation =
      "This will prevent downloading files that already exist in the folder. This is useful when you don't want to download the same file multiple times.";
}
