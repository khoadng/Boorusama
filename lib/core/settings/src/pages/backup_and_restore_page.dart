// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../backups/widgets.dart';
import '../widgets/settings_page_scaffold.dart';

class BackupAndRestorePage extends ConsumerStatefulWidget {
  const BackupAndRestorePage({
    super.key,
  });

  @override
  ConsumerState<BackupAndRestorePage> createState() =>
      _BackupAndRestorePageState();
}

class _BackupAndRestorePageState extends ConsumerState<BackupAndRestorePage> {
  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: Text(context.t.settings.backup_and_restore.backup_and_restore),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: const [
        BackupSettingsSection(),
      ],
    );
  }
}
