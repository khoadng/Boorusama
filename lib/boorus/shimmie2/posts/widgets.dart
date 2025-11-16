// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:i18n/i18n.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/posts/details/types.dart';
import '../../../core/posts/details_parts/types.dart';
import '../../../core/posts/details_parts/widgets.dart';
import '../../../core/posts/listing/providers.dart';
import '../../../core/posts/listing/widgets.dart';
import '../../../core/posts/post/types.dart';
import '../../../core/search/search/routes.dart';
import '../../../core/widgets/widgets.dart';
import '../../../foundation/toast.dart';
import '../extensions/providers.dart';
import '../extensions/types.dart';
import 'bulk_provider.dart';
import 'providers.dart';
import 'types.dart';

class Shimmie2UploaderFileDetailTile extends ConsumerWidget {
  const Shimmie2UploaderFileDetailTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<Shimmie2Post>(context);
    final uploaderName = post.uploaderName;

    return switch (uploaderName) {
      null => const SizedBox.shrink(),
      final name => UploaderFileDetailTile(
        uploaderName: name,
        onSearch: switch (ref.watch(shimmie2UploaderQueryProvider(post))) {
          final query? => () => goToSearchPage(
            ref,
            tag: query.resolveTag(),
          ),
          _ => null,
        },
      ),
    };
  }
}

final kShimmie2PostDetailsUIBuilder = PostDetailsUIBuilder(
  preview: {
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<Shimmie2Post>(),
  },
  full: {
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<Shimmie2Post>(),
    DetailsPart.tags: (context) =>
        const DefaultInheritedBasicTagsTile<Shimmie2Post>(),
    DetailsPart.fileDetails: (context) =>
        const DefaultInheritedFileDetailsSection<Shimmie2Post>(
          uploader: Shimmie2UploaderFileDetailTile(),
        ),
    DetailsPart.uploaderPosts: (context) =>
        const Shimmie2UploaderPostsSection(),
  },
);

class Shimmie2UploaderPostsSection extends ConsumerWidget {
  const Shimmie2UploaderPostsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<Shimmie2Post>(context);

    return UploaderPostsSection<Shimmie2Post>(
      query: ref.watch(
        shimmie2UploaderQueryProvider(post),
      ),
    );
  }
}

class Shimmie2MultiSelectionActions extends ConsumerWidget {
  const Shimmie2MultiSelectionActions({
    required this.postController,
    super.key,
  });

  final PostGridController<Post> postController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final controller = SelectionMode.of(context);
    final bulkOpNotifier = ref.watch(bulkOperationProvider(config).notifier);

    return DefaultMultiSelectionActions(
      postController: postController,
      extraActions: (selectedPosts) => switch (ref.watch(
        shimmie2ExtensionsProvider(config.url),
      )) {
        AsyncData(value: Shimmie2ExtensionsData(:final hasExtension))
            when hasExtension(KnownExtension.bulkActions) &&
                hasExtension(KnownExtension.favorites) &&
                config.passHash != null =>
          [
            BulkFavoriteButton(
              selectedPosts: selectedPosts,
              builder: (context, postIds, operating) => MultiSelectButton(
                onPressed: operating
                    ? null
                    : () async {
                        final success = await bulkOpNotifier.favorite(postIds);
                        if (context.mounted) {
                          _showToast(context, success);
                        }

                        if (success) {
                          controller.disable();
                        }
                      },
                icon: const Icon(
                  FontAwesomeIcons.heartCirclePlus,
                  size: 20,
                ),
                name: context.t.post.action.favorite,
              ),
            ),
            BulkFavoriteButton(
              selectedPosts: selectedPosts,
              builder: (context, postIds, operating) => MultiSelectButton(
                onPressed: operating
                    ? null
                    : () async {
                        final success = await bulkOpNotifier.unfavorite(
                          postIds,
                        );
                        if (context.mounted) {
                          _showToast(context, success);
                        }

                        if (success) {
                          controller.disable();
                        }
                      },
                icon: const Icon(
                  FontAwesomeIcons.heartCircleMinus,
                  size: 20,
                ),
                name: context.t.post.action.unfavorite,
              ),
            ),
          ],

        _ => [],
      },
    );
  }

  void _showToast(BuildContext context, bool success) {
    if (success) {
      showSuccessToast(
        context,
        context.t.favorites.update.success,
      );
    } else {
      showErrorToast(
        context,
        context.t.favorites.update.failure,
      );
    }
  }
}

class BulkFavoriteButton extends ConsumerWidget {
  const BulkFavoriteButton({
    super.key,
    required this.selectedPosts,
    required this.builder,
  });
  final List<Post> selectedPosts;
  final Widget Function(BuildContext context, List<int> postIds, bool operating)
  builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final bulkOpState = ref.watch(bulkOperationProvider(config));

    return bulkOpState.when(
      data: (data) => builder(
        context,
        selectedPosts.map((e) => e.id).toList(),
        data.isOperating,
      ),
      loading: () => builder(
        context,
        selectedPosts.map((e) => e.id).toList(),
        true,
      ),
      error: (_, _) => builder(
        context,
        selectedPosts.map((e) => e.id).toList(),
        false,
      ),
    );
  }
}
