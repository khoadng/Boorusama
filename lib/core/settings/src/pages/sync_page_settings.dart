// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../backups/transfer/sync/sync_page.dart';
import '../widgets/settings_page_scaffold.dart';

class SyncPageSettings extends ConsumerWidget {
  const SyncPageSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = SettingsPageScope.maybeOf(context)?.options;
    final isDense = options?.dense ?? false;

    if (isDense) {
      return const SyncPage();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sync')),
      body: const SyncPage(),
    );
  }
}
