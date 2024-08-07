// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/blacklist/blacklist.dart';
import 'package:boorusama/core/blacklists/blacklists.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/import_export_tag_button.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

//FIXME: This is a copy of lib/boorus/core/pages/blacklists/blacklisted_tag_page.dart
class BlacklistedTagsPage extends ConsumerWidget {
  const BlacklistedTagsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final tags = ref.watch(danbooruBlacklistedTagsProvider(config));

    return Scaffold(
      appBar: AppBar(
        title: const Text('blacklisted_tags.blacklisted_tags').tr(),
        actions: [
          _buildAddTagButton(context, ref),
          tags != null
              ? ImportExportTagButton(
                  tags: tags,
                  onImport: (tagString) => ref
                      .read(danbooruBlacklistedTagsProvider(config).notifier)
                      .addFromStringWithToast(tagString: tagString),
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: const SafeArea(child: BlacklistedTagsList()),
    );
  }

  Widget _buildAddTagButton(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () {
        goToBlacklistedTagsSearchPage(
          context,
          onSelectDone: (tagItems, currentQuery) {
            final tagString = [
              ...tagItems.map((e) => e.toString()),
              if (currentQuery.isNotEmpty) currentQuery,
            ].join(' ');

            ref
                .read(danbooruBlacklistedTagsProvider(ref.readConfig).notifier)
                .addWithToast(tag: tagString);
            context.navigator.pop();
          },
        );
      },
      icon: const Icon(Symbols.add),
    );
  }
}

// ignore: prefer-single-widget-per-file
class BlacklistedTagsList extends ConsumerWidget {
  const BlacklistedTagsList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final tags = ref.watch(danbooruBlacklistedTagsProvider(config));

    return tags != null
        ? CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: WarningContainer(
                    title: 'Limitation',
                    contentBuilder: (context) => Html(
                          style: {
                            'body': Style(
                              color: context.colorScheme.onSurface,
                              margin: Margins.zero,
                            ),
                          },
                          data: 'blacklisted_tags.limitation_notice'.tr(),
                        )),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tag = tags[index];

                    return BlacklistedTagTile(
                      tag: tag,
                      onRemoveTag: (tag) => ref
                          .read(danbooruBlacklistedTagsProvider(ref.readConfig)
                              .notifier)
                          .removeWithToast(tag: tag),
                      onEditTap: () {
                        goToBlacklistedTagsSearchPage(
                          context,
                          initialTags: tag.split(' '),
                          onSelectDone: (tagItems, currentQuery) {
                            final tagString = [
                              ...tagItems.map((e) => e.toString()),
                              if (currentQuery.isNotEmpty) currentQuery,
                            ].join(' ');

                            ref
                                .read(danbooruBlacklistedTagsProvider(
                                        ref.readConfig)
                                    .notifier)
                                .replace(
                                  oldTag: tag,
                                  newTag: tagString,
                                );
                            context.navigator.pop();
                          },
                        );
                      },
                    );
                  },
                  childCount: tags.length,
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }
}
