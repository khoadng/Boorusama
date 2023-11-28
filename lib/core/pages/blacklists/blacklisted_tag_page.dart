// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/import_export_tag_button.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';

class BlacklistedTagPage extends ConsumerWidget {
  const BlacklistedTagPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(globalBlacklistedTagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('blacklist.manage.title').tr(),
        actions: [
          IconButton(
            onPressed: () {
              goToBlacklistedTagsSearchPage(
                context,
                onSelectDone: (tagItems, currentQuery) {
                  final tagString = [
                    ...tagItems.map((e) => e.toString()),
                    if (currentQuery.isNotEmpty) currentQuery,
                  ].join(' ');

                  ref
                      .read(globalBlacklistedTagsProvider.notifier)
                      .addTagWithToast(tagString);
                  context.navigator.pop();
                },
              );
            },
            icon: const FaIcon(FontAwesomeIcons.plus),
          ),
          ImportExportTagButton(
            onImport: (tagString) => ref
                .read(globalBlacklistedTagsProvider.notifier)
                .addTagStringWithToast(tagString),
            tags: tags.map((e) => e.name).toList(),
          ),
        ],
      ),
      body: const SafeArea(child: BlacklistedTagsList()),
    );
  }
}

class BlacklistedTagsList extends ConsumerWidget {
  const BlacklistedTagsList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(globalBlacklistedTagsProvider);

    return tags.toOption().fold(
          () => const Center(child: CircularProgressIndicator()),
          (tags) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: WarningContainer(
                    contentBuilder: (context) => Html(
                          style: {
                            'body': Style(
                              color: context.colorScheme.onError,
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
                      tag: tag.name,
                      onRemoveTag: (_) => ref
                          .read(globalBlacklistedTagsProvider.notifier)
                          .removeTag(tag),
                      onEditTap: () {
                        goToBlacklistedTagsSearchPage(
                          context,
                          initialTags: tag.name.split(' '),
                          onSelectDone: (tagItems, currentQuery) {
                            final tagString = [
                              ...tagItems.map((e) => e.toString()),
                              if (currentQuery.isNotEmpty) currentQuery,
                            ].join(' ');

                            ref
                                .read(globalBlacklistedTagsProvider.notifier)
                                .updateTag(
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
          ),
        );
  }
}

// ignore: prefer-single-widget-per-file
class BlacklistedTagTile extends StatelessWidget {
  const BlacklistedTagTile({
    super.key,
    required this.tag,
    required this.onEditTap,
    required this.onRemoveTag,
  });

  final String tag;
  final VoidCallback onEditTap;
  final void Function(String tag) onRemoveTag;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(tag),
      trailing: PopupMenuButton(
        constraints: const BoxConstraints(minWidth: 150),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        onSelected: (value) {
          switch (value) {
            case 'remove':
              onRemoveTag.call(tag);
              break;
            case 'edit':
              onEditTap.call();
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'remove',
            child: const Text('blacklisted_tags.remove').tr(),
          ),
          PopupMenuItem(
            value: 'edit',
            child: const Text('blacklisted_tags.edit').tr(),
          ),
        ],
      ),
    );
  }
}
