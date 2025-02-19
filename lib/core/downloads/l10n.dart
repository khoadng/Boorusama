class DownloadTranslations {
  const DownloadTranslations._();

  static const String downloadManagerTitle = 'Downloads';

  static const String retryAllFailed = 'Retry all';
  static const String cancel = 'Cancel';

  static const String downloadFailedNotification = 'failed';
  static const String downloadCompletedNotification = 'completed';
  static const String downloadStartedNotification = 'Download started';
  static const String downloadNothingToClear = 'Nothing to clear';

  static const String downloadPath = 'settings.download.path';
  static const String downloadSelectFolder =
      'settings.download.select_a_folder';
  static const String downloadSelectFolderWarning =
      "The app can only download files inside public directories <b>({0})</b> for Android 11+. <br><br> Valid location examples:<br><b>[Internal]</b> /storage/emulated/0/Download <br><b>[SD card]</b> /storage/A1B2-C3D4/Download<br><br>Please choose another directory or create a new one if it doesn't exist. <br>This device's version is <b>{1}</b>.";

  static const String skipDownloadIfExists =
      'Ignore files that already downloaded';
  static const String skipDownloadIfExistsExplanation =
      "This will prevent downloading files that already exist in the folder. This is useful when you don't want to download the same file multiple times.";
}
