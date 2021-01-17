import 'package:boorusama/domain/posts/posts.dart';
import 'package:boorusama/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/setting_repository.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../post_filter.dart';

part 'latest_state.dart';
part 'latest_state_notifier.freezed.dart';

class LatestStateNotifier extends StateNotifier<LatestState> {
  final IPostRepository _postRepository;
  final ISettingRepository _settingRepository;

  LatestStateNotifier(ProviderReference ref)
      : _postRepository = ref.read(postProvider),
        _settingRepository = ref.read(settingsProvider),
        super(LatestState.initial());

  void getPosts(String query, int page) async {
    try {
      state = LatestState.loading();

      final dtos = await _postRepository.getPosts(query, page);
      final settings = await _settingRepository.load();
      final filteredPosts = filter(dtos, settings);

      state = LatestState.fetched(
        posts: filteredPosts,
      );
    } on DatabaseTimeOut catch (e) {}
  }

  void refresh() async {
    try {
      final dtos = await _postRepository.getPosts("", 1);
      final settings = await _settingRepository.load();
      final filteredPosts = filter(dtos, settings);

      state = LatestState.fetched(
        posts: filteredPosts,
      );
    } on DatabaseTimeOut catch (e) {}
  }
}
