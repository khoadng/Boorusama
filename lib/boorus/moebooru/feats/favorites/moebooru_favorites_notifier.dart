// Package imports:
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/ref.dart';
import '../../moebooru.dart';

var throttler = 0;

class MoebooruFavoritesNotifier extends FamilyNotifier<Set<String>?, int> {
  @override
  Set<String>? build(int arg) {
    return null;
  }

  void clear() {
    state = null;
    loadFavoriteUsers();
  }

  void refresh() {
    _loadFavoriteUsers();
  }

  Future<void> _loadFavoriteUsers() async {
    throttler++;
    await Future.delayed(
        Duration(milliseconds: min(100 * (throttler - 1), 3000)));
    throttler--;

    try {
      final client = ref.watch(moebooruClientProvider(ref.readConfigAuth));

      final users = await client.getFavoriteUsers(
        postId: arg,
        cancelToken: CancelToken(),
      );
      state = users;
    } catch (e) {
      state = null;
    }
  }

  Future<void> loadFavoriteUsers() async {
    if (state != null) {
      return;
    }

    await _loadFavoriteUsers();
  }
}
