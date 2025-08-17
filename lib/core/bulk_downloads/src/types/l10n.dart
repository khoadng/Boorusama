// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

class DownloadTranslations {
  const DownloadTranslations._();
  static String title(BuildContext context) => context.t.sideMenu.bulk_download;
  static String create(BuildContext context) =>
      context.t.bulk_downloads.new_download;
  static String createShort(BuildContext context) =>
      context.t.bulk_downloads.create;
  static final String empty = 'No active download sessions'.hc;
  static String delete(BuildContext context) => context.t.bulk_downloads.delete;
  static final String copyPath = 'Copy path'.hc;
  static String createdStatus(BuildContext context) =>
      context.t.bulk_downloads.created;
  static String download(BuildContext context) => context.t.download.download;
  static final String addToQueue = 'Add to List'.hc;
  static String allSkippedStatus(BuildContext context) =>
      context.t.bulk_downloads.completed_with_no_new_files;
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
