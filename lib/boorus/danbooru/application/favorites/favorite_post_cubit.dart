// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/domain/boorus.dart';

part 'favorite_post_state.dart';

class FavoritePostCubit extends Cubit<FavoritePostState> {
  final FavoritePostRepository _favoritePostRepository;
  final BooruUserIdentityProvider _userIdentityProvider;
  final CurrentBooruConfigRepository _currentBooruConfigRepository;
  final Map<int, bool> _favoriteCache = {};
  final int _limit;

  FavoritePostCubit({
    required FavoritePostRepository favoritePostRepository,
    required BooruUserIdentityProvider userIdentityProvider,
    required CurrentBooruConfigRepository currentBooruConfigRepository,
    required int limit,
  })  : _favoritePostRepository = favoritePostRepository,
        _userIdentityProvider = userIdentityProvider,
        _currentBooruConfigRepository = currentBooruConfigRepository,
        _limit = limit,
        super(FavoritePostInitial());

  Future<void> addFavorite(int postId) async {
    try {
      emit(FavoritePostLoading());
      final result = await _favoritePostRepository.addToFavorites(postId);
      if (result) {
        _favoriteCache[postId] = true;
        emit(FavoritePostListSuccess(favorites: _favoriteCache));
      } else {
        emit(FavoritePostFailure());
      }
    } catch (e) {
      emit(FavoritePostError(e.toString()));
    }
  }

  Future<void> removeFavorite(int postId) async {
    try {
      emit(FavoritePostLoading());
      final result = await _favoritePostRepository.removeFromFavorites(postId);
      if (result) {
        _favoriteCache[postId] = false;
        emit(FavoritePostListSuccess(favorites: _favoriteCache));
      } else {
        emit(FavoritePostFailure());
      }
    } catch (e) {
      emit(FavoritePostError(e.toString()));
    }
  }

  Future<void> checkFavorites(List<int> postIds) async {
    try {
      emit(FavoritePostLoading());
      final config = await _currentBooruConfigRepository.get();
      final userId = await _userIdentityProvider.getAccountIdFromConfig(config);
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Filter postIds that are not in the cache
      final postIdsToCheck = postIds
          .where((postId) => !_favoriteCache.containsKey(postId))
          .toList();

      if (postIdsToCheck.isNotEmpty) {
        final favorites = await _favoritePostRepository
            .filterFavoritesFromUserId(postIdsToCheck, userId, _limit);

        for (final favorite in favorites) {
          _favoriteCache[favorite.postId] = true;
        }
      }

      // Set false for postIds that are not in the cache and not in the favorites
      for (final postId in postIdsToCheck) {
        if (!_favoriteCache.containsKey(postId)) {
          _favoriteCache[postId] = false;
        }
      }

      emit(FavoritePostListSuccess(favorites: _favoriteCache));
    } catch (e) {
      emit(FavoritePostError(e.toString()));
    }
  }
}
