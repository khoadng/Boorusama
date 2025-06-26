// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../foundation/networking.dart';
import 'analytics_network_info.dart';
import 'analytics_providers.dart';

class NetworkListener extends ConsumerWidget {
  const NetworkListener({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      connectivityProvider,
      (previous, next) {
        next.when(
          data: (data) {
            ref.watch(analyticsProvider).whenData(
              (analytics) {
                if (data.isEmpty || data.contains(ConnectivityResult.none)) {
                  analytics?.updateNetworkInfo(
                    const AnalyticsNetworkInfo.disconnected(),
                  );
                } else {
                  analytics?.updateNetworkInfo(
                    AnalyticsNetworkInfo.connected(data.prettyString),
                  );
                }
              },
            );
          },
          error: (error, stackTrace) {
            ref.watch(analyticsProvider).whenData(
              (analytics) {
                analytics?.updateNetworkInfo(
                  AnalyticsNetworkInfo.error(error.toString()),
                );
              },
            );
          },
          loading: () {},
        );
      },
    );

    return child;
  }
}
