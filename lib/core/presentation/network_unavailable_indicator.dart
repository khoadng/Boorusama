// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

class NetworkUnavailableIndicator extends StatelessWidget {
  const NetworkUnavailableIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
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
