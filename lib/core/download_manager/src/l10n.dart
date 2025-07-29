// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import 'types/download_filter.dart';

class DownloadTranslations {
  const DownloadTranslations._();

  static final String downloadManagerTitle = 'Downloads'.hc;

  static final String retryAllFailed = 'Retry all'.hc;

  static final String downloadNothingToClear = 'Nothing to clear'.hc;
}

extension DownloadFilterLocalize on DownloadFilter? {
  String localize(BuildContext context) => switch (this) {
    DownloadFilter.pending => context.t.download.status.pending,
    DownloadFilter.paused => context.t.download.status.paused,
    DownloadFilter.inProgress => context.t.download.status.in_progress,
    DownloadFilter.completed => context.t.download.status.completed,
    DownloadFilter.canceled => context.t.download.status.canceled,
    DownloadFilter.failed => context.t.download.status.failed,
    null => context.t.download.status.unknown,
  };

  String emptyLocalize() => switch (this) {
    DownloadFilter.pending => 'No pending downloads'.hc,
    DownloadFilter.paused => 'No paused downloads'.hc,
    DownloadFilter.inProgress => 'No downloads in progress'.hc,
    DownloadFilter.completed => 'No completed downloads'.hc,
    DownloadFilter.canceled => 'No canceled downloads'.hc,
    DownloadFilter.failed => 'No failed downloads'.hc,
    null => 'No downloads'.hc,
  };
}
