// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:version/version.dart';

// Project imports:
import '../../theme/app_theme.dart';

Future<bool?> showVersionMismatchAlertDialog({
  required BuildContext context,
  required Version importVersion,
  required Version currentVersion,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return VersionMismatchAlertDialog(
        importVersion: importVersion,
        currentVersion: currentVersion,
      );
    },
  );
}

class VersionMismatchAlertDialog extends ConsumerWidget {
  const VersionMismatchAlertDialog({
    required this.importVersion, required this.currentVersion, super.key,
  });

  final Version importVersion;
  final Version currentVersion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Importing from a different version detected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.hintColor,
                ),
                children: [
                  const TextSpan(text: 'Current version: '),
                  TextSpan(
                    text: currentVersion.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.hintColor,
                ),
                children: [
                  const TextSpan(text: 'Import version: '),
                  TextSpan(
                    text: importVersion.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'The app version of the device you are trying to import is different from the current version of the app. This may cause compatibility issues.'
              '\n\nAre you sure you want to continue?',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Sure',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
