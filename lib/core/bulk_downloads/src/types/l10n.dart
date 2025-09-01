// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

class DownloadTranslations {
  const DownloadTranslations._();

  static String inProgressStatus(int? completed, BuildContext context) =>
      completed != null
      ? context.t.bulk_downloads.scanning_page.with_page(page: completed)
      : context.t.bulk_downloads.scanning_page.null_page;
  static String titleInfoCounter(num count, BuildContext context) =>
      context.t.bulk_downloads.file_counter(n: count);
}
