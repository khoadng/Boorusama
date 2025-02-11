// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../providers/bulk_download_notifier.dart';
import '../types/saved_download_task.dart';

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
  late final TextEditingController _pathController;
  late final TextEditingController _tagsController;
  late bool _notifications;
  late bool _skipIfExists;
  late int _perPage;
  late int _concurrency;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.savedTask.name);
    _pathController = TextEditingController(text: widget.savedTask.task.path);
    _tagsController = TextEditingController(text: widget.savedTask.task.tags);
    _notifications = widget.savedTask.task.notifications;
    _skipIfExists = widget.savedTask.task.skipIfExists;
    _perPage = widget.savedTask.task.perPage;
    _concurrency = widget.savedTask.task.concurrency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pathController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(bulkDownloadProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final updatedTask = widget.savedTask.task.copyWith(
                path: _pathController.text,
                notifications: _notifications,
                skipIfExists: _skipIfExists,
                tags: _tagsController.text,
                perPage: _perPage,
                concurrency: _concurrency,
              );

              await notifier.editTask(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pathController,
              decoration: const InputDecoration(
                labelText: 'Download Path',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Notifications'),
              value: _notifications,
              onChanged: (value) => setState(() => _notifications = value),
            ),
            SwitchListTile(
              title: const Text('Skip If Exists'),
              value: _skipIfExists,
              onChanged: (value) => setState(() => _skipIfExists = value),
            ),
            ListTile(
              title: const Text('Per Page'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => setState(() {
                      if (_perPage > 1) _perPage--;
                    }),
                  ),
                  Text('$_perPage'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => _perPage++),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Concurrency'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => setState(() {
                      if (_concurrency > 1) _concurrency--;
                    }),
                  ),
                  Text('$_concurrency'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => _concurrency++),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
