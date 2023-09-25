// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/widgets/import_export_tag_button.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';

//FIXME: This is a copy of lib/boorus/core/pages/blacklists/blacklisted_tag_page.dart
class BlacklistedTagsPage extends ConsumerWidget {
  const BlacklistedTagsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(danbooruBlacklistedTagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('blacklisted_tags.blacklisted_tags').tr(),
        actions: [
          _buildAddTagButton(context, ref),
          if (tags != null)
            ImportExportTagButton(
              tags: tags,
              onImport: (tagString) {
                final tags = sanitizeBlacklistTagString(tagString);

                if (tags == null) {
                  showErrorToast('Invalid tag format');
                  return;
                }

                //FIXME: should be handled inside the provider, not here. I'm just lazy. Also missing error handling
                for (final tag in tags) {
                  ref
                      .read(danbooruBlacklistedTagsProvider.notifier)
                      .add(tag: tag);
                }
              },
            ),
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
                .read(danbooruBlacklistedTagsProvider.notifier)
                .addWithToast(tag: tagString);
            context.navigator.pop();
          },
        );
      },
      icon: const FaIcon(FontAwesomeIcons.plus),
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
    final tags = ref.watch(danbooruBlacklistedTagsProvider);

    return tags.toOption().fold(
          () => const Center(child: CircularProgressIndicator()),
          (tags) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: WarningContainer(
                    contentBuilder: (context) => Html(
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
                          .read(danbooruBlacklistedTagsProvider.notifier)
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
                                .read(danbooruBlacklistedTagsProvider.notifier)
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
    return Material(
      color: Colors.transparent,
      child: Ink(
        child: ListTile(
          title: Text(tag),
          // ignore: no-empty-block
          onTap: () {},
          trailing: PopupMenuButton(
            constraints: const BoxConstraints(minWidth: 150),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                padding: EdgeInsets.zero,
                child: ListTile(
                  onTap: () {
                    context.navigator.pop();
                    onRemoveTag.call(tag);
                  },
                  title: const Text('blacklisted_tags.remove').tr(),
                  trailing: const FaIcon(
                    FontAwesomeIcons.trash,
                    size: 16,
                  ),
                ),
              ),
              PopupMenuItem(
                padding: EdgeInsets.zero,
                child: ListTile(
                  onTap: () {
                    context.navigator.pop();
                    onEditTap.call();
                  },
                  title: const Text('blacklisted_tags.edit').tr(),
                  trailing: const FaIcon(
                    FontAwesomeIcons.pen,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
