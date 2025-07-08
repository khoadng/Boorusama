// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

class DownloadTranslations {
  const DownloadTranslations._();
  static String title(BuildContext context) => context.t.sideMenu.bulk_download;
  static final String create = 'New download'.hc;
  static final String createShort = 'Create'.hc;
  static final String empty = 'No active download sessions'.hc;
  static final String delete = 'Delete'.hc;
  static final String copyPath = 'Copy path'.hc;
  static final String createdStatus = 'Created'.hc;
  static String download(BuildContext context) => context.t.download.download;
  static final String addToQueue = 'Add to List'.hc;
  static final String allSkippedStatus = 'Completed with no new files'.hc;
  static String inProgressStatus(int? completed) =>
      'Scanning${completed != null ? ' page $completed ' : ''}...'.hc;
  static String titleInfoCounter(bool plural) =>
      plural ? '{} files'.hc : '{} file'.hc;

  static String saveToFolder(BuildContext context) =>
      context.t.download.bulk_download_save_to_folder;
  static final String showAdvancedOptions = 'Show advanced options'.hc;
  static final String enableNotifications = 'Notifications'.hc;
  static String selectFolder(BuildContext context) =>
      context.t.settings.download.select_a_folder;

  static final String templates = 'Templates'.hc;
  static final String emptyTemplates = 'No templates'.hc;
  static final String createTemplate = 'Create a template'.hc;
  static final String templateCreated = 'Template created'.hc;
  static final String runTemplate = 'Run'.hc;
}
