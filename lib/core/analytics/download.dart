// Project imports:
import '../configs/config/types.dart';
import '../downloads/downloader/types.dart';
import 'analytics_interface.dart';

class AnalyticsDownloadObserver implements DownloadObserver {
  const AnalyticsDownloadObserver({
    required this.analytics,
    required this.getConfig,
  });

  final AnalyticsInterface? analytics;
  final BooruConfigAuth Function() getConfig;

  @override
  void onBulkDownloadStart({
    required int total,
  }) {
    final config = getConfig();
    analytics?.logEvent(
      'multiple_download_start',
      parameters: {
        'total': total,
        'hint_site': config.booruType.name,
        'url': Uri.tryParse(config.url)?.host,
      },
    );
  }

  @override
  void onSingleDownloadStart() {
    final auth = getConfig();
    analytics?.logEvent(
      'single_download_start',
      parameters: {
        'hint_site': auth.booruType.name,
        'url': Uri.tryParse(auth.url)?.host,
      },
    );
  }
}
