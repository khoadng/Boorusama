// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../configs/config/widgets.dart';
import '../../../posts/listing/types.dart';
import '../../../search/search/types.dart';
import '../generated/settings_index.g.dart';
import '../providers/settings_notifier.dart';
import '../providers/settings_provider.dart';
import '../widgets/setting_anchor.dart';
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
        SettingAnchor(
          id: SettingsIndex.search.autoFocus.id,
          child: KurumiSwitchListTile(
            title: Text(
              SettingsIndex.search.autoFocus.title(context),
            ),
            value: settings.autoFocusSearchBar,
            onChanged: (value) {
              notifer.updateSettings(
                settings.copyWith(
                  autoFocusSearchBar: value,
                ),
              );
            },
          ),
        ),
        SettingAnchor(
          id: SettingsIndex.search.persistentBar.id,
          child: KurumiSwitchListTile(
            title: Text(
              SettingsIndex.search.persistentBar.title(context),
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
        ),
        SettingAnchor(
          id: SettingsIndex.search.barPosition.id,
          child: KurumiSettingsTile(
            title: Text(
              SettingsIndex.search.barPosition.title(context),
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
        ),
        SettingAnchor(
          id: SettingsIndex.search.hideBookmarkedPosts.id,
          child: KurumiSwitchListTile(
            title: Text(
              SettingsIndex.search.hideBookmarkedPosts.title(context),
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
        ),
        const BooruConfigMoreSettingsRedirectCard.search(),
      ],
    );
  }
}
