import 'package:boorusama/boorus/danbooru/domain/posts/i_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../post_filter.dart';

part 'most_viewed_state.dart';
part 'most_viewed_state_notifier.freezed.dart';

class MostViewedStateNotifier extends StateNotifier<MostViewedState> {
  final IPostRepository _postRepository;
  final ISettingRepository _settingRepository;

  MostViewedStateNotifier(ProviderReference ref)
      : _postRepository = ref.read(postProvider),
        _settingRepository = ref.read(settingsProvider),
        super(MostViewedState.initial());

  void getPosts(DateTime date) async {
    try {
      state = MostViewedState.loading();

      final dtos = await _postRepository.getMostViewedPosts(date);
      final settings = await _settingRepository.load();
      final filteredPosts = filter(dtos, settings);

      state = MostViewedState.fetched(
        posts: filteredPosts,
      );
    } on DatabaseTimeOut catch (e) {
      state = MostViewedState.error(
          name: "Errors", message: "Something went wrong");
    }
  }

  void refresh(DateTime date) async {
    try {
      final dtos = await _postRepository.getMostViewedPosts(date);
      final settings = await _settingRepository.load();
      final filteredPosts = filter(dtos, settings);

      state = MostViewedState.fetched(
        posts: filteredPosts,
      );
    } on DatabaseTimeOut catch (e) {}
  }
}
