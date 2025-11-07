// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../../core/search/search/routes.dart';
import '../../../../../../core/tags/tag/providers.dart';
import '../../../../../../core/tags/tag/types.dart';
import '../../../../../../core/tags/tag/widgets.dart';
import '../../../../../../core/widgets/booru_popup_menu_button.dart';
import '../../../../configs/providers.dart';
import '../../../../tags/_shared/tag_list_notifier.dart';
import '../../../../tags/tag/widgets.dart';
import '../../../listing/providers.dart';
import '../../../post/types.dart';

class DanbooruTagsTile extends StatefulWidget {
  const DanbooruTagsTile({
    required this.post,
    super.key,
  });

  final DanbooruPost post;

  @override
  State<DanbooruTagsTile> createState() => _DanbooruTagsTileState();
}

class _DanbooruTagsTileState extends State<DanbooruTagsTile> {
  var _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return RawTagsTile(
      title: DanbooruTagsTileTitle(
        post: widget.post,
      ),
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (value) {
        setState(() {
          _isExpanded = value;
        });
      },
      children: [
        Column(
          children: [
            if (_isExpanded)
              Consumer(
                builder: (_, ref, _) {
                  final config = ref.watchConfigAuth;

                  return PostTagList(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    tags: ref
                        .watch(tagGroupsProvider((config, widget.post)))
                        .maybeWhen(
                          data: (data) => data,
                          orElse: () => null,
                        ),
                    itemBuilder: (context, tag) => DanbooruTagContextMenu(
                      tag: tag.rawName,
                      child: PostTagListChip(
                        tag: tag,
                        auth: config,
                        onTap: () => goToSearchPage(ref, tag: tag.rawName),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ],
    );
  }
}

class DanbooruTagsTileTitle extends ConsumerWidget {
  const DanbooruTagsTileTitle({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final tagDetails = ref.watch(
      danbooruTagListProvider(config),
    )[post.id];
    final count = tagDetails?.allTags.length ?? post.tags.length;
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(config));

    return RawTagsTileTitle(
      auth: config,
      post: post,
      count: count,
      menuItems: loginDetails.hasLogin()
          ? [
              BooruPopupMenuItem(
                title: Text(context.t.generic.action.edit),
                onTap: () => ref.danbooruEdit(post),
              ),
            ]
          : null,
    );
  }
}
