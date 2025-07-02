// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../client_provider.dart';

final moebooruFavoritesProvider =
    NotifierProvider.family<MoebooruFavoritesNotifier, Set<String>?, int>(
  MoebooruFavoritesNotifier.new,
);

CancelToken _cancelToken = CancelToken();

class MoebooruFavoritesNotifier extends FamilyNotifier<Set<String>?, int> {
  @override
  Set<String>? build(int arg) {
    return null;
  }

  void clear() {
    state = null;
    loadFavoriteUsers();
  }

  Future<void> loadFavoriteUsers() async {
    if (state != null) {
      return;
    }

    // Cancel the previous request before making a new one
    _cancelToken.cancel();

    // Create a new CancelToken for the new request
    _cancelToken = CancelToken();

    try {
      final client = ref.watch(moebooruClientProvider(ref.readConfigAuth));

      final users = await client.getFavoriteUsers(
        postId: arg,
        cancelToken: _cancelToken,
      );

      state = users;
    } catch (e) {
      state = null;
    }
  }
}
