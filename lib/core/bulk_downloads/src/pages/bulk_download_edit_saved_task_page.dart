// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../downloads/l10n.dart';
import '../../../info/device_info.dart';
import '../providers/create_download_options_notifier.dart';
import '../providers/saved_download_task_provider.dart';
import '../types/download_options.dart';
import '../types/saved_download_task.dart';
import 'create_download_options_sheet.dart';

class BulkDownloadEditSavedTaskPage extends ConsumerWidget {
  const BulkDownloadEditSavedTaskPage({
    required this.savedTask,
    super.key,
    this.edit = false,
  });

  final SavedDownloadTask savedTask;
  final bool edit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(savedDownloadTasksProvider.notifier);
    final initial = DownloadOptions.fromTask(savedTask.task);
    final navigator = Navigator.of(context);

    return CreateDownloadOptionsRawSheet(
      initial: initial,
      advancedToggle: false,
      actions: Builder(
        builder: (context) {
          final options = ref.watch(createDownloadOptionsProvider(initial));
          final androidSdkInt = ref.watch(
            deviceInfoProvider
                .select((value) => value.androidDeviceInfo?.version.sdkInt),
          );
          final validOptions = options.valid(androidSdkInt: androidSdkInt);

          return Row(
            spacing: 16,
            children: [
              Expanded(
                child: ElevatedButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide.none,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    DownloadTranslations.cancel,
                  ).tr(),
                ),
              ),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  onPressed: validOptions
                      ? () async {
                          if (edit) {
                            await notifier.edit(
                              savedTask.copyWith(
                                task: options.toTask(
                                  id: savedTask.task.id,
                                ),
                              ),
                            );
                          } else {
                            await notifier.createFromOptions(options);
                          }

                          navigator.pop();
                        }
                      : null,
                  child: const Text(
                    'Save',
                  ).tr(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
