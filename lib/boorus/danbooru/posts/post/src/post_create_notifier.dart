// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/posts/rating/rating.dart';
import 'converter.dart';
import 'danbooru_post.dart';

final danbooruPostCreateProvider = AsyncNotifierProvider.autoDispose
    .family<DanbooruPostCreateNotifier, DanbooruPost?, BooruConfigAuth>(
        DanbooruPostCreateNotifier.new);

class DanbooruPostCreateNotifier
    extends AutoDisposeFamilyAsyncNotifier<DanbooruPost?, BooruConfigAuth> {
  @override
  FutureOr<DanbooruPost?> build(BooruConfigAuth arg) {
    return null;
  }

  Future<void> create({
    required int mediaAssetId,
    required int uploadMediaAssetId,
    required Rating rating,
    required String source,
    required List<String> tags,
    String? artistCommentaryTitle,
    String? artistCommentaryDesc,
    String? translatedCommentaryTitle,
    String? translatedCommentaryDesc,
    int? parentId,
  }) async {
    final client = ref.read(danbooruClientProvider(arg));

    state = const AsyncLoading();

    try {
      final post = await client.createPost(
        mediaAssetId: mediaAssetId,
        uploadMediaAssetId: uploadMediaAssetId,
        rating: rating.toShortString(),
        source: source,
        tags: tags,
        artistCommentaryTitle: artistCommentaryTitle,
        artistCommentaryDesc: artistCommentaryDesc,
        translatedCommentaryTitle: translatedCommentaryTitle,
        translatedCommentaryDesc: translatedCommentaryDesc,
        parentId: parentId,
      );

      state = AsyncData(postDtoToPostNoMetadata(post));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
