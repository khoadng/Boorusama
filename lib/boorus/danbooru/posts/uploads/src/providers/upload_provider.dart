// Dart imports:
import 'dart:async';

// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config.dart';
import '../../../../../../core/posts/rating/rating.dart';
import '../../../../client_provider.dart';
import '../../../post/post.dart';
import '../../../post/providers.dart';
import '../types/danbooru_upload_post.dart';

final danbooruUploadNotifierProvider =
    AutoDisposeNotifierProvider.family<
      DanbooruUploadNotifier,
      DanbooruUploadState,
      BooruConfigAuth
    >(DanbooruUploadNotifier.new);

class DanbooruUploadState extends Equatable {
  const DanbooruUploadState({
    this.tags = '',
    this.rating,
    this.originalTitle,
    this.originalDescription,
    this.translatedTitle,
    this.translatedDescription,
    this.parentId,
    this.isSubmitting = false,
    this.error,
  });

  final String tags;
  final Rating? rating;
  final String? originalTitle;
  final String? originalDescription;
  final String? translatedTitle;
  final String? translatedDescription;
  final int? parentId;
  final bool isSubmitting;
  final Object? error;

  bool canSubmit(String? sourceUrl) =>
      tags.trim().isNotEmpty && rating != null && sourceUrl != null;

  List<String> get tagList =>
      tags.split(' ').where((e) => e.isNotEmpty).toList();

  DanbooruUploadState copyWith({
    String? tags,
    Rating? Function()? rating,
    String? Function()? originalTitle,
    String? Function()? originalDescription,
    String? Function()? translatedTitle,
    String? Function()? translatedDescription,
    int? Function()? parentId,
    bool? isSubmitting,
    Object? Function()? error,
  }) {
    return DanbooruUploadState(
      tags: tags ?? this.tags,
      rating: rating != null ? rating() : this.rating,
      originalTitle: originalTitle != null
          ? originalTitle()
          : this.originalTitle,
      originalDescription: originalDescription != null
          ? originalDescription()
          : this.originalDescription,
      translatedTitle: translatedTitle != null
          ? translatedTitle()
          : this.translatedTitle,
      translatedDescription: translatedDescription != null
          ? translatedDescription()
          : this.translatedDescription,
      parentId: parentId != null ? parentId() : this.parentId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [
    tags,
    rating,
    originalTitle,
    originalDescription,
    translatedTitle,
    translatedDescription,
    parentId,
    isSubmitting,
    error,
  ];
}

class DanbooruUploadNotifier
    extends AutoDisposeFamilyNotifier<DanbooruUploadState, BooruConfigAuth> {
  @override
  DanbooruUploadState build(BooruConfigAuth arg) {
    return const DanbooruUploadState();
  }

  void updateTags(String tags) {
    state = state.copyWith(tags: tags);
  }

  void updateRating(Rating? rating) {
    state = state.copyWith(rating: () => rating);
  }

  void updateOriginalTitle(String? title) {
    state = state.copyWith(originalTitle: () => title);
  }

  void updateOriginalDescription(String? description) {
    state = state.copyWith(originalDescription: () => description);
  }

  void updateTranslatedTitle(String? title) {
    state = state.copyWith(translatedTitle: () => title);
  }

  void updateTranslatedDescription(String? description) {
    state = state.copyWith(translatedDescription: () => description);
  }

  void updateFromSource({
    ArtistSourceCommentaryDto? artistCommentary,
  }) {
    switch (artistCommentary) {
      case ArtistSourceCommentaryDto(
        :final dtextTitle?,
        :final dtextDescription?,
      ):
        state = state.copyWith(
          originalTitle: dtextTitle == state.originalTitle
              ? null
              : () => dtextTitle,
          originalDescription: dtextDescription == state.originalDescription
              ? null
              : () => dtextDescription,
        );
      case _:
      // Do nothing
    }
  }

  void updateParentId(String parentId) {
    final id = int.tryParse(parentId);
    if (id == null) return;
    state = state.copyWith(parentId: () => id);
  }

  Future<DanbooruPost?> submit(DanbooruUploadPost post) async {
    if (!state.canSubmit(post.pageUrl)) return null;

    state = state.copyWith(isSubmitting: true, error: () => null);

    final rating = state.rating;
    if (rating == null) {
      state = state.copyWith(
        isSubmitting: false,
        error: () => 'Rating is required',
      );
      return null;
    }

    try {
      final client = ref.read(danbooruClientProvider(arg));
      final createdPost = await client.createPost(
        mediaAssetId: post.mediaAssetId,
        uploadMediaAssetId: post.uploadMediaAssetId,
        rating: rating.toShortString(),
        source: post.pageUrl,
        tags: state.tagList,
        artistCommentaryTitle: state.originalTitle,
        artistCommentaryDesc: state.originalDescription,
        translatedCommentaryTitle: state.translatedTitle,
        translatedCommentaryDesc: state.translatedDescription,
        parentId: state.parentId,
      );

      state = state.copyWith(isSubmitting: false);

      return postDtoToPostNoMetadata(createdPost);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: () => e);
      return null;
    }
  }
}
