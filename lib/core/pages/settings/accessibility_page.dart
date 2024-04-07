// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/pages/settings/widgets/settings_tile.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class AccessibilityPage extends ConsumerStatefulWidget {
  const AccessibilityPage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  ConsumerState<AccessibilityPage> createState() => _AccessibilityPageState();
}

class _AccessibilityPageState extends ConsumerState<AccessibilityPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return ConditionalParentWidget(
      condition: widget.hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('settings.accessibility.accessibility').tr(),
        ),
        body: child,
      ),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          primary: false,
          children: [
            SwitchListTile(
              title: const Text(
                      'settings.accessibility.reverseBooruConfigSelectorScrollDirection')
                  .tr(),
              value: settings.reverseBooruConfigSelectorScrollDirection,
              onChanged: (value) => ref.updateSettings(
                settings.copyWith(
                  booruConfigSelectorScrollDirection: value
                      ? BooruConfigScrollDirection.reversed
                      : BooruConfigScrollDirection.normal,
                ),
              ),
            ),
            SettingsTile(
              title: const Text('settings.accessibility.swipeAreaToOpenSidebar')
                  .tr(),
              subtitle: Text(
                'settings.accessibility.swipeAreaToOpenSidebarDescription',
                style: TextStyle(
                  color: context.theme.hintColor,
                ),
              ).tr(),
              selectedOption: settings.swipeAreaToOpenSidebarPercentage,
              items: getSwipeAreaPossibleValue(),
              onChanged: (newValue) {
                ref.updateSettings(settings.copyWith(
                    swipeAreaToOpenSidebarPercentage: newValue));
              },
              optionBuilder: (value) => Text(
                '$value%',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
