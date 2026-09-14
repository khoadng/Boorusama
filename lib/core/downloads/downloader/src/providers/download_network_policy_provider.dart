// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../foundation/info/device_info.dart';
import '../../../../../foundation/networking/network_provider.dart';
import '../../../../../foundation/networking/network_state.dart';
import '../../../../../foundation/platform.dart';
import '../../../../router.dart';
import '../types/download_network_policy.dart';
import '../widgets/download_network_dialog.dart';

final downloadNetworkSessionProvider = Provider<DownloadNetworkSession>(
  (ref) => DownloadNetworkSession(),
);

final wifiDownloadConstraintSupportedProvider = Provider<bool>((ref) {
  if (!ref.watch(appPlatformProvider).isAndroid) return true;

  final sdkInt = ref.watch(
    deviceInfoProvider.select(
      (value) => value.androidDeviceInfo?.version.sdkInt,
    ),
  );
  return sdkInt != null && sdkInt >= AndroidVersions.android9.apiLevel;
});

Future<DownloadNetworkConstraint?> resolveDownloadNetworkConstraint(
  Ref ref,
  DownloadNetworkPolicy policy,
) async {
  final wifiDownloadConstraintSupported = ref.read(
    wifiDownloadConstraintSupportedProvider,
  );
  final isMobileDataOnly = switch (policy) {
    DownloadNetworkPolicy.askOnMobileData => (await ref.read(
      currentConnectivityProvider.future,
    )).usesMobileDataWithoutWifi,
    _ => false,
  };

  return ref
      .read(downloadNetworkSessionProvider)
      .resolve(
        policy: policy,
        isMobileDataOnly: isMobileDataOnly,
        prompt: () async {
          final context = ref
              .read(appNavigationProvider)
              .navigatorKey
              .currentState
              ?.context;
          if (context == null || !context.mounted) {
            return null;
          }

          return showDownloadNetworkDialog(
            context,
            wifiDownloadConstraintSupported: wifiDownloadConstraintSupported,
          );
        },
      );
}
