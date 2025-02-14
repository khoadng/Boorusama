// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../downloads/widgets/download_folder_selector_section.dart';
import '../../../info/device_info.dart';
import '../../../search/histories/history.dart';
import '../../../settings/settings.dart';
import '../../../settings/widgets.dart';
import '../../l10n.dart';
import '../providers/bulk_download_notifier.dart';
import '../types/saved_download_task.dart';
import '../widgets/bulk_download_tag_list.dart';

class BulkDownloadEditSavedTaskPage extends ConsumerStatefulWidget {
  const BulkDownloadEditSavedTaskPage({
    required this.savedTask,
    super.key,
  });

  final SavedDownloadTask savedTask;

  @override
  ConsumerState<BulkDownloadEditSavedTaskPage> createState() =>
      _BulkDownloadEditSavedTaskPageState();
}

class _BulkDownloadEditSavedTaskPageState
    extends ConsumerState<BulkDownloadEditSavedTaskPage> {
  late final TextEditingController _nameController;
  late String _path;
  late List<String> _tags;
  late bool _notifications;
  late bool _skipIfExists;
  late int _perPage;
  late int _concurrency;
  late String? _quality;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.savedTask.name);
    _path = widget.savedTask.task.path;
    _tags = widget.savedTask.task.tags
            ?.split(' ')
            .where((t) => t.isNotEmpty)
            .toList() ??
        [];
    _notifications = widget.savedTask.task.notifications;
    _skipIfExists = widget.savedTask.task.skipIfExists;
    _perPage = widget.savedTask.task.perPage;
    _concurrency = widget.savedTask.task.concurrency;
    _quality = widget.savedTask.task.quality;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (!_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _onHistoryTap(SearchHistory history) {
    _addTag(history.query);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(bulkDownloadProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit template').tr(),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final updatedTask = widget.savedTask.copyWith(
                name: _nameController.text,
                task: widget.savedTask.task.copyWith(
                  path: _path,
                  notifications: _notifications,
                  skipIfExists: _skipIfExists,
                  tags: _tags.join(' '),
                  perPage: _perPage,
                  concurrency: _concurrency,
                ),
              );

              await notifier.editSavedTask(
                updatedTask,
              );

              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Template name',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: DownloadFolderSelectorSection(
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                storagePath: _path,
                deviceInfo: ref.watch(deviceInfoProvider),
                onPathChanged: (path) => setState(() => _path = path),
              ),
            ),
            const SizedBox(height: 16),
            BulkDownloadTagList(
              tags: _tags,
              onSubmit: _addTag,
              onRemove: _removeTag,
              onHistoryTap: _onHistoryTap,
            ),
            SwitchListTile(
              title: const Text(
                DownloadTranslations.bulkDownloadEnableNotifications,
              ).tr(),
              value: _notifications,
              onChanged: (value) => setState(() => _notifications = value),
            ),
            SwitchListTile(
              title: const Text(DownloadTranslations.skipDownloadIfExists).tr(),
              value: _skipIfExists,
              onChanged: (value) => setState(() => _skipIfExists = value),
            ),
            SettingsTile(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text('settings.download.quality').tr(),
              selectedOption: _quality ?? DownloadQuality.original.name,
              items: DownloadQuality.values.map((e) => e.name).toList(),
              onChanged: (value) {
                setState(() => _quality = value);
              },
              optionBuilder: (value) =>
                  Text('settings.download.qualities.$value').tr(),
            ),
          ],
        ),
      ),
    );
  }
}
