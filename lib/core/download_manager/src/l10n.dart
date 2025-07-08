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
  String localize() => switch (this) {
    DownloadFilter.pending => 'Pending'.hc,
    DownloadFilter.paused => 'Paused'.hc,
    DownloadFilter.inProgress => 'In Progress'.hc,
    DownloadFilter.completed => 'Completed'.hc,
    DownloadFilter.canceled => 'Canceled'.hc,
    DownloadFilter.failed => 'Failed'.hc,
    null => 'Unknown'.hc,
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
