// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../url_launcher.dart';
import '../types/update_status.dart';

class AppUpdateDialog extends StatelessWidget {
  const AppUpdateDialog({
    required this.status,
    super.key,
  });

  final UpdateAvailable status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.t.app_update.update_available,
                    style: textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _VersionChangeVisualizedText(status: status),
              ],
            ),
            const Divider(thickness: 1.5),
            Row(
              children: [
                Text(
                  context.t.app_update.whats_new,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 4,
                ),
                child: SingleChildScrollView(
                  child: Row(
                    children: [
                      Expanded(
                        child: MarkdownBody(
                          data: status.releaseNotes,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(context.t.app_update.later),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: () {
                    launchExternalUrlString(status.storeUrl);
                    Navigator.of(context).pop();
                  },
                  child: Text(context.t.app_update.update),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionChangeVisualizedText extends StatelessWidget {
  const _VersionChangeVisualizedText({
    required this.status,
  });

  final UpdateAvailable status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: status.currentVersion,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.outline,
            ),
          ),
          const TextSpan(text: '  ➞  '),
          TextSpan(
            text: status.storeVersion,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
