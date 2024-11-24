// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/settings/widgets/widgets/settings_page_scaffold.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_tile.dart';

class LayoutPage extends ConsumerWidget {
  const LayoutPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return SettingsPageScaffold(
      title: const Text('Layout').tr(),
      children: [
        SettingsHeader(label: 'settings.appearance.booru_config'.tr()),
        SettingsTile(
          title: const Text('settings.appearance.booru_config_placement').tr(),
          selectedOption: settings.booruConfigSelectorPosition,
          items: const [...BooruConfigSelectorPosition.values],
          onChanged: (value) => ref.updateSettings(
              settings.copyWith(booruConfigSelectorPosition: value)),
          optionBuilder: (value) => Text(value.localize()),
        ),
        SettingsTile(
          title: const Text('Label').tr(),
          selectedOption: settings.booruConfigLabelVisibility,
          items: const [...BooruConfigLabelVisibility.values],
          onChanged: (value) => ref.updateSettings(
              settings.copyWith(booruConfigLabelVisibility: value)),
          optionBuilder: (value) => Text(value.localize()),
        ),
      ],
    );
  }
}
