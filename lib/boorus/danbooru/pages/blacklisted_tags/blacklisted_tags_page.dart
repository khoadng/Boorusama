// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/features/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/ui/warning_container.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/functional.dart';

class BlacklistedTagsPage extends ConsumerWidget {
  const BlacklistedTagsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('blacklisted_tags.blacklisted_tags').tr(),
        actions: [
          _buildAddTagButton(context, ref),
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
          onSelectDone: (tagItems) {
            ref
                .read(danbooruBlacklistedTagsProvider.notifier)
                .add(tag: tagItems.map((e) => e.toString()).join(' '));
            Navigator.of(context).pop();
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
                child: WarningContainer(contentBuilder: (context) {
                  return Html(data: 'blacklisted_tags.limitation_notice'.tr());
                }),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tag = tags[index];

                    return BlacklistedTagTile(
                      tag: tag,
                      onRemoveTag: (tag) => ref
                          .read(
                            danbooruBlacklistedTagsProvider.notifier,
                          )
                          .remove(tag: tag),
                      onEditTap: () {
                        goToBlacklistedTagsSearchPage(
                          context,
                          initialTags: tag.split(' '),
                          onSelectDone: (tagItems) {
                            ref
                                .read(danbooruBlacklistedTagsProvider.notifier)
                                .replace(
                                  oldTag: tag,
                                  newTag: tagItems
                                      .map((e) => e.toString())
                                      .join(' '),
                                );
                            Navigator.of(context).pop();
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
                    Navigator.of(context).pop();
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
                    Navigator.of(context).pop();
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
