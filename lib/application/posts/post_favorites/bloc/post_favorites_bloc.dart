import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/accounts/i_favorite_post_repository.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/posts/post_dto.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_favorites_event.dart';
part 'post_favorites_state.dart';

part 'post_favorites_bloc.freezed.dart';

class PostFavoritesBloc extends Bloc<PostFavoritesEvent, PostFavoritesState> {
  final IPostRepository _postRepository;
  final IFavoritePostRepository _favoritePostRepository;
  final ISettingRepository _settingRepository;

  PostFavoritesBloc(
    this._postRepository,
    this._favoritePostRepository,
    this._settingRepository,
  ) : super(PostFavoritesState.initial());

  @override
  Stream<PostFavoritesState> mapEventToState(
    PostFavoritesEvent event,
  ) async* {
    yield* event.map(
      fetched: (e) => _mapFetchedToState(e),
      added: (e) => _mapAddedToState(e),
      removed: (e) => _mapRemovedToState(e),
    );
  }

  Stream<PostFavoritesState> _mapFetchedToState(_Fetched event) async* {
    yield const PostFavoritesState.loading();
    final settings = await _settingRepository.load();
    final dtos =
        await _postRepository.getPosts("ordfav:${event.username}", event.page);

    final posts = <Post>[];
    dtos.forEach((dto) {
      if (dto.file_url != null &&
          dto.preview_file_url != null &&
          dto.large_file_url != null) {
        posts.add(dto.toEntity());
      }
    });

    final filteredPosts = posts
        .where((post) => !post.containsBlacklistedTag(settings.blacklistedTags))
        .toList();

    yield PostFavoritesState.loaded(posts: filteredPosts);
  }

  Stream<PostFavoritesState> _mapAddedToState(_Added event) async* {
    await _favoritePostRepository.addToFavorites(event.postId);
    yield const PostFavoritesState.addCompleted();
  }

  Stream<PostFavoritesState> _mapRemovedToState(_Removed event) async* {
    await _favoritePostRepository.removeFromFavorites(event.postId);
    yield const PostFavoritesState.removeComplated();
  }
}
