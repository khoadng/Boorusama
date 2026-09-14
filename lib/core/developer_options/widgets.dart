// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../settings/src/widgets/settings_page_scaffold.dart';
import 'l10n.dart';
import 'providers.dart';

class DeveloperOptionsPage extends ConsumerWidget {
  const DeveloperOptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final automaticMediaLoadingEnabled = ref.watch(
      automaticMediaLoadingEnabledProvider,
    );
    final l10n = context.t.developerOptions;

    return SettingsPageScaffold(
      title: Text(l10n.title),
      children: [
        KurumiSwitchListTile(
          title: Text(l10n.blockAutomaticMedia),
          subtitle: Text(l10n.blockAutomaticMediaDescription),
          value: !automaticMediaLoadingEnabled,
          onChanged: (blocked) => ref
              .read(developerOptionsNotifierProvider.notifier)
              .setAutomaticMediaLoadingEnabled(!blocked),
        ),
      ],
    );
  }
}
