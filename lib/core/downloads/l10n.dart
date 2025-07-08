// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

class DownloadTranslations {
  static final String downloadFailedNotification = 'failed'.hc;
  static final String downloadCompletedNotification = 'completed'.hc;
  static final String downloadStartedNotification = 'Download started'.hc;

  static String downloadPath(BuildContext context) =>
      context.t.settings.download.path;
  static String downloadSelectFolder(BuildContext context) =>
      context.t.settings.download.select_a_folder;
  static String downloadSelectFolderWarning(BuildContext context) =>
      context.t.download.bulk_download_folder_select_warning;

  static final String skipDownloadIfExists = 'Skip existing files'.hc;
  static final String skipDownloadIfExistsExplanation =
      "This will prevent downloading files that already exist in the folder. This is useful when you don't want to download the same file multiple times."
          .hc;
}
