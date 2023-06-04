// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feat/settings/settings.dart';
import 'package:boorusama/boorus/core/pages/widgets/conditional_parent_widget.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';

class SearchSettingsPage extends ConsumerStatefulWidget {
  const SearchSettingsPage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  ConsumerState<SearchSettingsPage> createState() => _SearchSettingsPageState();
}

class _SearchSettingsPageState extends ConsumerState<SearchSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return ConditionalParentWidget(
      condition: widget.hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('settings.search').tr(),
        ),
        body: child,
      ),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          primary: false,
          children: [
            if (isMobilePlatform())
              ListTile(
                title: const Text(
                  'Auto focus search bar when first open search view',
                ),
                trailing: Switch(
                  activeColor: Theme.of(context).colorScheme.primary,
                  value: settings.autoFocusSearchBar,
                  onChanged: (value) {
                    ref.updateSettings(settings.copyWith(
                      autoFocusSearchBar: value,
                    ));
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
