import 'package:boorusama/application/home/post_view_model.dart';
import 'package:boorusama/domain/posts/post_name_generator.dart';
import 'package:boorusama/domain/posts/posts.dart';
import 'package:boorusama/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/setting_repository.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../post_filter.dart';

part 'browse_all_state.dart';
part 'browse_all_state_notifier.freezed.dart';

class BrowseAllStateNotifier extends StateNotifier<BrowseAllState> {
  final IPostRepository _postRepository;
  final PostNameGenerator _postNameGenerator;
  final ISettingRepository _settingRepository;

  BrowseAllStateNotifier(ProviderReference ref)
      : _postRepository = ref.read(postProvider),
        _postNameGenerator = ref.read(postNameGeneratorProvider),
        _settingRepository = ref.read(settingsProvider),
        super(BrowseAllState.initial());

  void getPosts(String query, int page) async {
    try {
      state = BrowseAllState.loading();

      final dtos = await _postRepository.getPosts(query, 1);
      final settings = await _settingRepository.load();
      final filteredPosts = filter(dtos, settings);
      final postVms = getPostVms(filteredPosts, _postNameGenerator);

      state = BrowseAllState.fetched(
        posts: postVms,
        page: page,
        query: query,
      );
    } on DatabaseTimeOut catch (e) {}
  }

  void refresh() async {
    try {
      final dtos = await _postRepository.getPosts("", 1);
      final settings = await _settingRepository.load();
      final filteredPosts = filter(dtos, settings);
      final postVms = getPostVms(filteredPosts, _postNameGenerator);

      state = BrowseAllState.fetched(
        posts: postVms,
        page: 1,
        query: "",
      );
    } on DatabaseTimeOut catch (e) {}
  }

  void getMorePosts(
      List<PostViewModel> currentPosts, String query, int page) async {
    try {
      final nextPage = page + 1;
      final dtos = await _postRepository.getPosts(query, nextPage);
      final settings = await _settingRepository.load();
      final filteredPosts = filter(dtos, settings);
      final postVms = getPostVms(filteredPosts, _postNameGenerator);

      state = BrowseAllState.fetched(
        posts: currentPosts..addAll(postVms),
        page: nextPage,
        query: query,
      );
    } on DatabaseTimeOut catch (e) {}
  }
}
