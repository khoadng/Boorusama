// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../configs/manage.dart';

class ImportBooruConfigsAlertDialog extends StatelessWidget {
  const ImportBooruConfigsAlertDialog({
    super.key,
    required this.data,
  });

  final BooruConfigExportData data;

  @override
  Widget build(BuildContext context) {
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
              'Importing ${data.data.length} profiles',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'This will override ALL your current profiles, are you sure?',
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
