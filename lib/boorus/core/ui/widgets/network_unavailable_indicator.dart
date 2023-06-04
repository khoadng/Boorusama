// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';

class NetworkUnavailableIndicator extends StatelessWidget {
  const NetworkUnavailableIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 8,
          top: hasStatusBar() ? MediaQuery.of(context).viewPadding.top : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 16,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: const Text('network.unavailable').tr(),
            ),
          ],
        ),
      ),
    );
  }
}

class NetworkConnectingIndicator extends StatelessWidget {
  const NetworkConnectingIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 8,
          top: hasStatusBar() ? MediaQuery.of(context).viewPadding.top : 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 6),
              child: Text('Connecting...'),
            ),
          ],
        ),
      ),
    );
  }
}
