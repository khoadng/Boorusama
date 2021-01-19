import 'package:boorusama/boorus/danbooru/domain/posts/i_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/time_scale.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../post_filter.dart';

part 'curated_state.dart';
part 'curated_state_notifier.freezed.dart';

class CuratedStateNotifier extends StateNotifier<CuratedState> {
  final IPostRepository _postRepository;
  final ISettingRepository _settingRepository;

  CuratedStateNotifier(ProviderReference ref)
      : _postRepository = ref.read(postProvider),
        _settingRepository = ref.read(settingsProvider),
        super(CuratedState.initial());

  void getPosts(DateTime date, int page, TimeScale scale) async {
    try {
      state = CuratedState.loading();

      final dtos = await _postRepository.getCuratedPosts(date, page, scale);
      final settings = await _settingRepository.load();
      final filteredPosts = filter(dtos, settings);

      state = CuratedState.fetched(
        posts: filteredPosts,
      );
    } on DatabaseTimeOut catch (e) {
      state =
          CuratedState.error(name: "Errors", message: "Something went wrong");
    }
  }

  void refresh(DateTime date, TimeScale scale) async {
    try {
      final page = 1;
      state = CuratedState.refreshing();

      final dtos = await _postRepository.getCuratedPosts(date, page, scale);
      final settings = await _settingRepository.load();
      final filteredPosts = filter(dtos, settings);

      state = CuratedState.fetched(
        posts: filteredPosts,
      );
    } on DatabaseTimeOut catch (e) {}
  }
}
