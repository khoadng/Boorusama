// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

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
          title: const Text('settings.search.search').tr(),
        ),
        body: child,
      ),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          primary: false,
          children: [
            ListTile(
              title: const Text('settings.search.auto_focus_search_bar').tr(),
              trailing: Switch(
                activeColor: context.colorScheme.primary,
                value: settings.autoFocusSearchBar,
                onChanged: (value) {
                  ref.updateSettings(settings.copyWith(
                    autoFocusSearchBar: value,
                  ));
                },
              ),
            ),
            ListTile(
              title: const Text(
                      'settings.search.hide_bookmarked_posts_from_search_results')
                  .tr(),
              trailing: Switch(
                activeColor: context.colorScheme.primary,
                value: settings.shouldFilterBookmarks,
                onChanged: (value) {
                  ref.updateSettings(settings.copyWith(
                    bookmarkFilterType: value
                        ? BookmarkFilterType.hideAll
                        : BookmarkFilterType.none,
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
