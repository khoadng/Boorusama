// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/images/booru_image.dart';
import '../../../../../core/posts/listing/providers.dart';
import '../../../../../core/posts/listing/widgets.dart';
import '../../../../../core/posts/rating/types.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../../foundation/info/package_info.dart';
import '../../../configs/providers.dart';
import '../../../favgroups/favgroups/routes.dart';
import '../../../tags/_shared/tag_list_notifier.dart';
import '../../../tags/edit/widgets.dart';
import '../../../users/user/providers.dart';
import '../../post/types.dart';

class DanbooruMultiSelectionActions extends ConsumerWidget {
  const DanbooruMultiSelectionActions({
    required this.postController,
    super.key,
  });

  final PostGridController<DanbooruPost> postController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(config));
    final controller = SelectionMode.of(context);

    return DefaultMultiSelectionActions(
      postController: postController,
      extraActions: (selectedPosts) => [
        if (loginDetails.hasLogin())
          MultiSelectButton(
            onPressed: selectedPosts.isNotEmpty
                ? () async {
                    final shouldEnd = await goToAddToFavoriteGroupSelectionPage(
                      context,
                      selectedPosts,
                    );
                    if (shouldEnd != null && shouldEnd) {
                      controller.disable();
                    }
                  }
                : null,
            icon: const Icon(Symbols.add),
            name: 'Add to Group'.hc,
          ),
        if (ref.watch(isDevEnvironmentProvider))
          if (loginDetails.hasLogin())
            ref
                .watch(danbooruCurrentUserProvider(config))
                .when(
                  data: (user) => user?.level.isUnres ?? false
                      ? MultiSelectButton(
                          onPressed: selectedPosts.isNotEmpty
                              ? () async {
                                  final shouldEnd =
                                      await goToMassEditRatingSheet(
                                        context,
                                        ref,
                                        selectedPosts,
                                      );
                                  if (shouldEnd != null && shouldEnd) {
                                    controller.disable();
                                  }
                                }
                              : null,
                          icon: const Icon(Symbols.edit_square),
                          name: 'Edit Rating'.hc,
                        )
                      : MultiSelectButton.shrink(),
                  error: (error, _) => MultiSelectButton.shrink(),
                  loading: () => MultiSelectButton.shrink(),
                ),
      ],
    );
  }
}

Future<bool?> goToMassEditRatingSheet(
  BuildContext context,
  WidgetRef ref,
  List<DanbooruPost> posts,
) {
  return showBooruModalBottomSheet<bool?>(
    context: context,
    builder: (context) {
      return MassEditRatingSheet(
        posts: posts,
      );
    },
  );
}

final _selectedRatingProvider = StateProvider.autoDispose<Rating?>(
  (ref) => null,
);

class MassEditRatingSheet extends ConsumerWidget {
  const MassEditRatingSheet({
    required this.posts,
    super.key,
  });

  final List<DanbooruPost> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRating = ref.watch(_selectedRatingProvider);
    final notifier = ref.watch(
      danbooruTagListProvider(ref.watchConfigAuth).notifier,
    );

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TagEditRatingSelectorSection(
              rating: selectedRating,
              onChanged: (rating) {
                ref.read(_selectedRatingProvider.notifier).state = rating;
              },
            ),
            SizedBox(
              height: 240,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 4,
                ),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: BooruImage(
                    config: ref.watchConfigAuth,
                    imageUrl: posts[index].url720x720,
                    aspectRatio: posts[index].aspectRatio,
                  ),
                ),
                itemCount: posts.length,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 8,
              ),
              child: FilledButton(
                onPressed: selectedRating != null
                    ? () async {
                        Navigator.of(context).pop(true);
                        for (final post in posts) {
                          await notifier.setTags(
                            post.id,
                            rating: selectedRating,
                          );
                        }
                      }
                    : null,
                child: Text('Submit'.hc),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
