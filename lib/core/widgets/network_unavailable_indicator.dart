// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class NetworkUnavailableIndicator extends StatelessWidget {
  const NetworkUnavailableIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 8,
          top: hasStatusBar() ? MediaQuery.viewPaddingOf(context).top : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Symbols.wifi_off,
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
      color: context.theme.colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 8,
          top: hasStatusBar() ? MediaQuery.viewPaddingOf(context).top : 0,
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
