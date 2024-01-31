// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';

class ShowTagListPage extends ConsumerWidget {
  const ShowTagListPage({
    super.key,
    required this.tags,
    this.onAddToBlacklist,
    this.onAddToGlobalBlacklist,
    this.onAddToFavoriteTags,
    this.onOpenWiki,
  });

  final List<Tag> tags;
  final void Function(Tag tag)? onAddToBlacklist;
  final void Function(Tag tag)? onAddToGlobalBlacklist;
  final void Function(Tag tag)? onAddToFavoriteTags;
  final void Function(Tag tag)? onOpenWiki;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: context.navigator.pop,
            icon: const Icon(Symbols.close),
          ),
        ],
        toolbarHeight: kToolbarHeight * 0.75,
        automaticallyImplyLeading: false,
        title: const Text('Tags'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          title: Text(
            tags[index].displayName,
            style: TextStyle(
              color: ref.getTagColor(context, tags[index].category.name),
            ),
          ),
          trailing: BooruPopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 'add_to_blacklist':
                  onAddToBlacklist?.call(tags[index]);
                  break;
                case 'add_to_global_blacklist':
                  onAddToGlobalBlacklist?.call(tags[index]);
                  break;
                case 'add_to_favorite_tags':
                  onAddToFavoriteTags?.call(tags[index]);
                case 'open_wiki':
                  onOpenWiki?.call(tags[index]);
                case 'copy':
                  Clipboard.setData(
                    ClipboardData(
                      text: tags[index].rawName,
                    ),
                  ).then(
                    (_) => showSimpleSnackBar(
                      context: context,
                      content: const Text('Copied'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: {
              'copy': const Text('Copy'),
              if (onAddToBlacklist != null)
                'add_to_blacklist':
                    const Text('post.detail.add_to_blacklist').tr(),
              'add_to_global_blacklist': const Text('Add to global blacklist'),
              'add_to_favorite_tags': const Text('Add to favorites'),
              if (onOpenWiki != null)
                'open_wiki': const Text('post.detail.open_wiki').tr(),
            },
          ),
        ),
        itemCount: tags.length,
      ),
    );
  }
}
