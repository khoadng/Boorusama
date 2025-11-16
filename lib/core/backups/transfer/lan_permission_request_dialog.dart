// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../widgets/widgets.dart';

class LanPermissionRequestDialog extends StatelessWidget {
  const LanPermissionRequestDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BooruDialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Symbols.wifi,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Network Permission Required'.hc,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildExplanation(theme),

            const SizedBox(height: 16),

            _buildFeatureList(theme),

            const SizedBox(height: 16),

            _buildActions(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'This app needs to access your local network to find and connect with nearby devices for data transfer.'
            .hc,
        style: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildFeatureList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This permission enables:'.hc,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _FeatureItem(
          icon: Symbols.cloud_sync,
          text: 'Transfer data between devices'.hc,
        ),
        _FeatureItem(
          icon: Symbols.devices,
          text: 'Discover nearby devices on your network'.hc,
        ),
        _FeatureItem(
          icon: Symbols.backup,
          text: 'Import and export backups wirelessly'.hc,
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                context.t.generic.action.cancel,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('Continue'.hc),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool?> showLanPermissionRequestDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const LanPermissionRequestDialog(),
  );
}
