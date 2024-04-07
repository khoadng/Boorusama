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
          title: const Text('Accessibility'),
        ),
        body: child,
      ),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          primary: false,
          children: [
            SwitchListTile(
              title: const Text('Reverse scroll direction of booru profiles'),
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
              title: const Text("Sidebar's swiping area"),
              subtitle: Text(
                'The amount of area on the left side of the screen that can be used to trigger a swipe. Large values will block all horizontal gestures like the pagination swipe gesture.',
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
