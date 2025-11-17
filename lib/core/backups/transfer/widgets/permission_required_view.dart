// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../foundation/permissions.dart';

class PermissionRequiredView extends ConsumerWidget {
  const PermissionRequiredView({
    super.key,
    this.onPermissionGranted,
  });

  final VoidCallback? onPermissionGranted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Network Permission Required'.hc,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'This app needs local network access to discover and connect with nearby devices for data transfer.'
                  .hc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                await ref
                    .read(localNetworkPermissionProvider.notifier)
                    .requestPermission();

                onPermissionGranted?.call();
              },
              icon: const Icon(Icons.wifi),
              label: Text('Grant Permission'.hc),
            ),
          ],
        ),
      ),
    );
  }
}
