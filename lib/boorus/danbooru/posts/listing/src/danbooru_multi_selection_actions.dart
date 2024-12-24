// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/images/booru_image.dart';
import '../../../../../core/info/package_info.dart';
import '../../../../../core/posts/listing/widgets.dart';
import '../../../../../core/posts/rating/rating.dart';
import '../../../tags/_shared/tag_list_notifier.dart';
import '../../../tags/edit/widgets.dart';
import '../../../users/user/providers.dart';
import '../../../users/user/user.dart';
import '../../favgroups/favgroups/routes.dart';
import '../../post/post.dart';

class DanbooruMultiSelectionActions extends ConsumerWidget {
  const DanbooruMultiSelectionActions({
    required this.controller,
    super.key,
  });

  final MultiSelectController<DanbooruPost> controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return DefaultMultiSelectionActions(
      controller: controller,
      extraActions: [
        if (config.hasLoginDetails())
          ValueListenableBuilder(
            valueListenable: controller.selectedItemsNotifier,
            builder: (context, selectedPosts, child) {
              return IconButton(
                onPressed: selectedPosts.isNotEmpty
                    ? () async {
                        final shouldEnd =
                            await goToAddToFavoriteGroupSelectionPage(
                          context,
                          selectedPosts,
                        );
                        if (shouldEnd != null && shouldEnd) {
                          controller.disableMultiSelect();
                        }
                      }
                    : null,
                icon: const Icon(Symbols.add),
              );
            },
          ),
        if (ref.watch(isDevEnvironmentProvider))
          if (config.hasLoginDetails())
            ref.watch(danbooruCurrentUserProvider(config)).when(
                  data: (user) => DanbooruUserLevel.of(user?.level).isUnres
                      ? ValueListenableBuilder(
                          valueListenable: controller.selectedItemsNotifier,
                          builder: (context, selectedPosts, child) {
                            return IconButton(
                              onPressed: selectedPosts.isNotEmpty
                                  ? () async {
                                      final shouldEnd =
                                          await goToMassEditRatingSheet(
                                        context,
                                        ref,
                                        selectedPosts,
                                      );
                                      if (shouldEnd != null && shouldEnd) {
                                        controller.disableMultiSelect();
                                      }
                                    }
                                  : null,
                              icon: const Icon(Symbols.edit_square),
                            );
                          },
                        )
                      : const SizedBox.shrink(),
                  error: (error, _) => const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
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
  return showModalBottomSheet<bool?>(
    context: context,
    builder: (context) {
      return MassEditRatingSheet(
        posts: posts,
      );
    },
  );
}

final _selectedRatingProvider =
    StateProvider.autoDispose<Rating?>((ref) => null);

class MassEditRatingSheet extends ConsumerWidget {
  const MassEditRatingSheet({
    required this.posts,
    super.key,
  });

  final List<DanbooruPost> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRating = ref.watch(_selectedRatingProvider);
    final notifier =
        ref.watch(danbooruTagListProvider(ref.watchConfigAuth).notifier);

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
                vertical: 16,
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
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
