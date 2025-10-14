// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/posts/sources/types.dart';
import '../../../../../../core/search/suggestions/providers.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../../foundation/animations/constants.dart';
import '../../../../../../foundation/toast.dart';
import '../../../../sources/providers.dart';
import '../../../../tags/edit/widgets.dart';
import '../../../post/providers.dart';
import '../../../post/types.dart';
import '../internal_widgets/similar_tab.dart';
import '../internal_widgets/source_tab.dart';
import '../internal_widgets/tag_tab.dart';
import '../providers/providers.dart';
import '../providers/upload_provider.dart';
import '../types/danbooru_upload_post.dart';
import '../types/utils.dart';
import 'tag_edit_scaffold.dart';
import 'tag_edit_upload_text_controller.dart';

class TagEditUploadPage extends ConsumerStatefulWidget {
  const TagEditUploadPage({
    required this.post,
    super.key,
    this.onSubmitted,
  });

  final DanbooruUploadPost post;
  final void Function()? onSubmitted;

  @override
  ConsumerState<TagEditUploadPage> createState() => _TagEditUploadPageState();
}

class _TagEditUploadPageState extends ConsumerState<TagEditUploadPage> {
  final viewController = TagEditViewController();

  @override
  void dispose() {
    viewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;

    ref.listen(
      danbooruUploadNotifierProvider(config).select((state) => state.error),
      (previous, next) {
        if (next != null) {
          showErrorToast(
            context,
            next.toString(),
            duration: AppDurations.longToast,
          );
        }
      },
    );

    return TagEditUploadScaffold(
      viewController: viewController,
      imageFooterBuilder: () {
        final text = Text(
          buildDetailsText(widget.post),
        );

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ref
              .watch(danbooruIqdbResultProvider(widget.post.mediaAssetId))
              .maybeWhen(
                data: (results) {
                  final posts = results
                      .map(
                        (e) => e.post != null
                            ? postDtoToPostNoMetadata(e.post!)
                            : null,
                      )
                      .nonNulls
                      .toList();
                  final pixelPerfectDup = posts.firstWhereOrNull(
                    (e) => e.pixelHash == widget.post.pixelHash,
                  );

                  return pixelPerfectDup != null || results.isNotEmpty
                      ? Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            text,
                            const SizedBox(width: 8),
                            if (pixelPerfectDup != null)
                              CompactChip(
                                textColor: Colors.white,
                                label: 'Pixel-Perfect Duplicate',
                                onTap: () {},
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                              )
                            else
                              CompactChip(
                                textColor: Colors.white,
                                label: 'Duplicate',
                                onTap: () {},
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                              ),
                          ],
                        )
                      : text;
                },
                orElse: () => text,
              ),
        );
      },
      contentBuilder: (maxHeight) {
        final sourceData = ref.watch(
          danbooruSourceProvider(widget.post.pageUrl),
        );
        final initialTags = sourceData.maybeWhen(
          data: (source) => source.artist?.artists?.map((e) => e.name ?? ''),
          orElse: () => null,
        );

        return TagEditUploadTextControllerScope(
          initialText: initialTags != null ? '${initialTags.join(' ')} ' : '',
          builder: (controller) => DefaultTabController(
            length: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTabBar(controller),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        TagEditUploadTag(
                          textEditingController: controller,
                          post: widget.post,
                        ),
                        TagEditUploadSource(
                          post: widget.post,
                        ),
                        TagEditUploadSimilar(
                          post: widget.post,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      aspectRatio: widget.post.aspectRatio ?? 1,
      imageUrl: widget.post.url720x720,
    );
  }

  Widget _buildTabBar(
    TagEditUploadTextController textEditingController,
  ) {
    final config = ref.watchConfigAuth;
    final notifier = ref.watch(
      danbooruUploadNotifierProvider(config).notifier,
    );

    return Row(
      children: [
        Expanded(
          child: TabBar(
            isScrollable: true,
            tabs: [
              const Tab(text: 'Tags'),
              const Tab(text: 'Source'),
              ref
                  .watch(danbooruIqdbResultProvider(widget.post.mediaAssetId))
                  .maybeWhen(
                    data: (results) => results.isNotEmpty
                        ? Badge.count(
                            offset: const Offset(16, 4),
                            count: results.length,
                            child: const Tab(text: 'Similar'),
                          )
                        : const Tab(text: 'Similar'),
                    orElse: () => const Tab(text: 'Similar'),
                  ),
            ],
          ),
        ),
        ValueListenableBuilder(
          valueListenable: textEditingController,
          builder: (context, value, child) {
            final rating = ref.watch(
              danbooruUploadNotifierProvider(
                config,
              ).select((state) => state.rating),
            );
            final isSubmitting = ref.watch(
              danbooruUploadNotifierProvider(
                config,
              ).select((state) => state.isSubmitting),
            );

            final canSubmit =
                value.text.isNotEmpty &&
                rating != null &&
                widget.post.source.url != null;

            return TextButton(
              onPressed: canSubmit && !isSubmitting
                  ? () async {
                      notifier.updateTags(value.text);
                      final post = await notifier.submit(widget.post);
                      if (post != null) {
                        widget.onSubmitted?.call();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    }
                  : null,
              child: Text('Post'.hc),
            );
          },
        ),
      ],
    );
  }
}

class TagEditUploadTextControllerScope extends ConsumerStatefulWidget {
  const TagEditUploadTextControllerScope({
    required this.initialText,
    required this.builder,
    super.key,
  });

  final String initialText;
  final Widget Function(TagEditUploadTextController controller) builder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TagEditUploadTextControllerScopeState();
}

class _TagEditUploadTextControllerScopeState
    extends ConsumerState<TagEditUploadTextControllerScope> {
  late final textEditingController = TagEditUploadTextController(
    text: widget.initialText,
  );

  @override
  void initState() {
    super.initState();
    textEditingController.lastWordNotifier.addListener(_onLastWordChanged);
  }

  @override
  void dispose() {
    textEditingController.lastWordNotifier.removeListener(_onLastWordChanged);
    textEditingController.dispose();
    super.dispose();
  }

  void _onLastWordChanged() {
    final lastWord = textEditingController.lastWord;
    if (lastWord != null) {
      ref
          .read(suggestionsNotifierProvider(ref.readConfigAuth).notifier)
          .getSuggestions(lastWord);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(textEditingController);
  }
}
