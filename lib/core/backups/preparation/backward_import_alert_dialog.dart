// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../foundation/info/package_info.dart';
import '../../themes/theme/types.dart';

Future<bool?> showBackwardImportAlertDialog({
  required BuildContext context,
  required Version exportVersion,
}) {
  return showDialog<bool>(
    routeSettings: const RouteSettings(name: 'backward_import'),
    context: context,
    builder: (context) {
      return BackwardImportAlertDialog(
        exportVersion: exportVersion,
      );
    },
  );
}

class BackwardImportAlertDialog extends ConsumerWidget {
  const BackwardImportAlertDialog({
    required this.exportVersion,
    super.key,
  });

  final Version exportVersion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final appVersion = ref.watch(appVersionProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              context.t.settings.backup_and_restore.backward_import.title,
              style: const TextStyle(
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
                  color: colorScheme.hintColor,
                ),
                children: [
                  TextSpan(
                    text:
                        '${context.t.settings.backup_and_restore.backward_import.current_version}: ',
                  ),
                  TextSpan(
                    text: appVersion?.toString() ?? 'Unknown',
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
                  color: colorScheme.hintColor,
                ),
                children: [
                  TextSpan(
                    text:
                        '${context.t.settings.backup_and_restore.backward_import.exported_version}: ',
                  ),
                  TextSpan(
                    text: exportVersion.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context
                  .t
                  .settings
                  .backup_and_restore
                  .backward_import
                  .reconfirm_question,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.errorContainer,
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  context.t.settings.backup_and_restore.import,
                  style: TextStyle(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  context.t.generic.action.cancel,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
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
