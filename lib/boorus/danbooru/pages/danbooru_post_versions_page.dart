// Flutter imports:
import 'package:boorusama/core/router.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/boorus/danbooru/feats/versions/versions.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/time.dart';
import 'package:boorusama/widgets/widgets.dart';

class DanbooruPostVersionsPage extends ConsumerWidget {
  const DanbooruPostVersionsPage({
    super.key,
    required this.postId,
    required this.previewUrl,
  });

  final int postId;
  final String previewUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versions = ref.watch(danbooruPostVersionsProvider(postId));

    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 300,
              ),
              child: BooruImage(
                imageUrl: previewUrl,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          const SliverSizedBox(
            height: 16,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            sliver: versions.when(
              data: (data) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final version = data[index];

                      return Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(8),
                          color: context.colorScheme.secondaryContainer,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: context.colorScheme.surface,
                                        ),
                                        child: Text(
                                          '${version.version}',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Material(
                                          color: Colors.transparent,
                                          elevation: 0,
                                          child: InkWell(
                                            onTap: () => goToUserDetailsPage(
                                              ref,
                                              context,
                                              uid: version.updater.id,
                                              username: version.updater.name,
                                            ),
                                            child: Text(
                                              version.updater.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: version.updater
                                                    .getColor(context),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        ' • ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        version.updatedAt.fuzzify(
                                          locale: context.locale,
                                        ),
                                        style: TextStyle(
                                          color: context.theme.hintColor,
                                        ),
                                      ),
                                      TagChangedText(
                                        title: '',
                                        added: version.addedTags.toSet(),
                                        removed: version.removedTags.toSet(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    children: [
                                      ...version.addedTags.map(
                                        (e) => PostVersionTagText(
                                          tag: e,
                                          style: const TextStyle(
                                            color: Colors.green,
                                          ),
                                          onTap: () =>
                                              goToSearchPage(context, tag: e),
                                        ),
                                      ),
                                      ...version.removedTags.map(
                                        (e) => PostVersionTagText(
                                          tag: e,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            decorationColor: Colors.red,
                                          ),
                                          onTap: () =>
                                              goToSearchPage(context, tag: e),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: data.length,
                  ),
                );
              },
              loading: () => SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    child: const SizedBox(
                      height: 12,
                      width: 12,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
              error: (error, stackTrace) => SliverToBoxAdapter(
                child: Center(
                  child: Text(error.toString()),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class PostVersionTagText extends StatelessWidget {
  const PostVersionTagText({
    super.key,
    required this.tag,
    required this.style,
    this.onTap,
  });

  final String tag;
  final TextStyle style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 1,
          ),
          child: Text(
            tag,
            style: style,
          ),
        ),
      ),
    );
  }
}
