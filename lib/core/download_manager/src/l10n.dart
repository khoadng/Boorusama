// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import 'types/download_filter.dart';

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

  String emptyLocalize(BuildContext context) => switch (this) {
    DownloadFilter.pending =>
      context.t.download.empty_states.no_pending_downloads,
    DownloadFilter.paused =>
      context.t.download.empty_states.no_paused_downloads,
    DownloadFilter.inProgress =>
      context.t.download.empty_states.no_downloads_in_progress,
    DownloadFilter.completed =>
      context.t.download.empty_states.no_completed_downloads,
    DownloadFilter.canceled =>
      context.t.download.empty_states.no_canceled_downloads,
    DownloadFilter.failed =>
      context.t.download.empty_states.no_failed_downloads,
    null => context.t.download.empty_states.no_downloads,
  };
}
