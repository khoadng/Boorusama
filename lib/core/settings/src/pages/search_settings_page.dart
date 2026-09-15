// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../configs/config/widgets.dart';
import '../../../posts/listing/types.dart';
import '../../../search/search/types.dart';
import '../providers/settings_notifier.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_page_scaffold.dart';

class SearchSettingsPage extends ConsumerStatefulWidget {
  const SearchSettingsPage({
    super.key,
  });

  @override
  ConsumerState<SearchSettingsPage> createState() => _SearchSettingsPageState();
}

class _SearchSettingsPageState extends ConsumerState<SearchSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifer = ref.watch(settingsNotifierProvider.notifier);

    return SettingsPageScaffold(
      title: Text(context.t.settings.search.search),
      children: [
        KurumiSwitchListTile(
          title: Text(context.t.settings.search.auto_focus_search_bar),
          value: settings.autoFocusSearchBar,
          onChanged: (value) {
            notifer.updateSettings(
              settings.copyWith(
                autoFocusSearchBar: value,
              ),
            );
          },
        ),
        KurumiSwitchListTile(
          title: Text(
            context.t.settings.search.search_bar.scroll_behavior.persistent,
          ),
          subtitle: Text(
            context
                .t
                .settings
                .search
                .search_bar
                .scroll_behavior
                .persistent_description,
          ),
          value: settings.searchBarScrollBehavior.persistSearchBar,
          onChanged: (value) {
            notifer.updateSettings(
              settings.copyWith(
                searchBarScrollBehavior: value
                    ? SearchBarScrollBehavior.persistent
                    : SearchBarScrollBehavior.autoHide,
              ),
            );
          },
        ),
        KurumiSettingsTile(
          title: Text(
            context.t.settings.search.search_bar.position.search_bar_position,
          ),
          subtitle: Text('Only applies in portrait mode'.hc),
          selectedOption: settings.searchBarPosition,
          items: SearchBarPosition.values,
          onChanged: (value) {
            notifer.updateSettings(
              settings.copyWith(searchBarPosition: value),
            );
          },
          optionBuilder: (value) => Text(value.localize(context)),
        ),
        KurumiSwitchListTile(
          title: Text(
            context.t.settings.search.hide_bookmarked_posts_from_search_results,
          ),
          value: settings.bookmarkFilterType.shouldFilterBookmarks,
          onChanged: (value) {
            notifer.updateSettings(
              settings.copyWith(
                bookmarkFilterType: value
                    ? BookmarkFilterType.hideAll
                    : BookmarkFilterType.none,
              ),
            );
          },
        ),
        const BooruConfigMoreSettingsRedirectCard.search(),
      ],
    );
  }
}
