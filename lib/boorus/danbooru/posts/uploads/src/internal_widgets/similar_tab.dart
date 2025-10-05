// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/images/booru_image.dart';
import '../../../../../../core/theme.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../post/post.dart';
import '../../../post/providers.dart';
import '../providers/providers.dart';
import '../providers/upload_notifier.dart';
import '../types/danbooru_upload_post.dart';
import '../types/utils.dart';

class TagEditUploadSimilar extends ConsumerWidget {
  const TagEditUploadSimilar({
    super.key,
    required this.post,
  });

  final DanbooruUploadPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final uploadNotifier = ref.watch(
      danbooruUploadNotifierProvider(config).notifier,
    );

    return CustomScrollView(
      slivers: [
        const SliverSizedBox(height: 16),
        SliverToBoxAdapter(
          child: BooruTextFormField(
            autocorrect: false,
            onChanged: (value) {
              uploadNotifier.updateParentId(value);
            },
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Parent ID',
            ),
          ),
        ),
        const SliverSizedBox(height: 16),
        ref
            .watch(danbooruIqdbResultProvider(post.mediaAssetId))
            .maybeWhen(
              data: (results) {
                return results.isNotEmpty
                    ? SliverGrid.builder(
                        itemCount: results.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.8,
                            ),
                        itemBuilder: (context, index) {
                          final post = results[index].post != null
                              ? postDtoToPostNoMetadata(results[index].post!)
                              : DanbooruPost.empty();

                          final similar = results[index].score ?? 0;

                          return Column(
                            children: [
                              Expanded(
                                child: BooruImage(
                                  config: ref.watchConfigAuth,
                                  fit: BoxFit.contain,
                                  imageUrl: post.url720x720,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  buildDetailsText(post),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              // xx% similar
                              Text(
                                '${similar.toInt()}% Similar',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.hintColor,
                                    ),
                              ),
                            ],
                          );
                        },
                      )
                    : SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            'No similar images found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      );
              },
              orElse: () => const SliverSizedBox.shrink(),
            ),
      ],
    );
  }
}
