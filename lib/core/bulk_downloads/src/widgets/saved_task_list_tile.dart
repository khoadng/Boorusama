// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../foundation/toast.dart';
import '../../../premiums/routes.dart';
import '../../../widgets/widgets.dart';
import '../pages/bulk_download_edit_saved_task_page.dart';
import '../providers/saved_download_task_provider.dart';
import '../providers/saved_task_lock_notifier.dart';
import '../routes/routes.dart';
import '../types/download_configs.dart';
import '../types/l10n.dart';
import '../types/saved_download_task.dart';

class SavedTaskListTile extends ConsumerWidget {
  const SavedTaskListTile({
    required this.savedTask,
    super.key,
    this.enableTap = true,
  });

  final SavedDownloadTask savedTask;
  final bool enableTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(savedDownloadTasksProvider.notifier);
    final isLocked = ref.watch(isSavedTaskLockedProvider(savedTask.task.id));
    final listTileTheme = Theme.of(context).listTileTheme;
    final currentRouteName = ModalRoute.of(context)?.settings.name;

    final downloadConfigs = currentRouteName != kBulkdownload
        ? DownloadConfigs(
            onDownloadStart: () {
              showSimpleSnackBar(
                context: context,
                content: Text(
                  'Downloading ${savedTask.name}...',
                ),
              );
            },
          )
        : null;

    return GrayedOut(
      opacity: 0.2,
      grayedOut: isLocked,
      onTap: () {
        goToPremiumPage(ref);
      },
      stackOverlay: const [
        Positioned.fill(
          child: Icon(
            FontAwesomeIcons.lock,
            color: Colors.white,
          ),
        ),
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: enableTap
                ? () async {
                    await showBooruModalBottomSheet(
                      context: context,
                      routeSettings:
                          const RouteSettings(name: 'bulk_download_create'),
                      builder: (_) => BulkDownloadEditSavedTaskPage(
                        savedTask: savedTask,
                        edit: true,
                      ),
                    );
                  }
                : null,
            onLongPress: enableTap
                ? () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => _ModalOptions(
                        savedTask: savedTask,
                        onDuplicate: () {
                          notifier.duplicate(savedTask);
                        },
                        onDelete: () {
                          notifier.delete(savedTask);
                        },
                        onRun: () {
                          notifier.run(
                            savedTask,
                            downloadConfigs: downloadConfigs,
                          );
                        },
                      ),
                    );
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          savedTask.task.prettyTags ?? 'Untitled',
                          style: listTileTheme.titleTextStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          savedTask.task.path,
                          style: listTileTheme.subtitleTextStyle,
                        ),
                      ],
                    ),
                  ),
                  _ActionButton(
                    icon: const Icon(FontAwesomeIcons.play),
                    onPressed: () {
                      notifier.run(
                        savedTask,
                        downloadConfigs: downloadConfigs,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModalOptions extends StatelessWidget {
  const _ModalOptions({
    required this.savedTask,
    required this.onDelete,
    required this.onRun,
    required this.onDuplicate,
  });

  final SavedDownloadTask savedTask;
  final void Function() onDelete;
  final void Function() onRun;
  final void Function() onDuplicate;

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const DragLine(),
          const SizedBox(height: 8),
          ListTile(
            title: const Text(DownloadTranslations.runTemplate).tr(),
            onTap: () {
              onRun();
              navigator.pop();
            },
          ),
          ListTile(
            title: const Text('generic.action.duplicate').tr(),
            onTap: () {
              onDuplicate();
              navigator.pop();
            },
          ),
          ListTile(
            title: Text(
              'generic.action.delete',
              style: TextStyle(
                color: colorScheme.error,
              ),
            ).tr(),
            onTap: () {
              onDelete();
              navigator.pop();
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.onPressed,
    required this.icon,
  });

  final VoidCallback onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircularIconButton(
      padding: const EdgeInsets.all(8),
      backgroundColor: colorScheme.surfaceContainer,
      icon: Theme(
        data: ThemeData(
          iconTheme: IconThemeData(
            color: colorScheme.onSurfaceVariant,
            fill: 1,
            size: 18,
          ),
        ),
        child: icon,
      ),
      onPressed: onPressed,
    );
  }
}
