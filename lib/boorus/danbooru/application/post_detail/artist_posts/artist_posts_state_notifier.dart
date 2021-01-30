// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/all.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import '../../black_listed_filter_decorator.dart';
import '../../no_image_filter_decorator.dart';

part 'artist_posts_state.dart';

part 'artist_posts_state_notifier.freezed.dart';

final artistPostsStateNotifierProvider =
    StateNotifierProvider<ArtistPostsStateNotifier>((ref) {
  final postRepo = ref.watch(postProvider);
  final settingsRepo = ref.watch(settingsProvider.future);
  final filteredPostRepo = BlackListedFilterDecorator(
      postRepository: postRepo, settingRepository: settingsRepo);
  final removedNullImageRepo =
      NoImageFilterDecorator(postRepository: filteredPostRepo);
  return ArtistPostsStateNotifier(postRepository: removedNullImageRepo);
});

class ArtistPostsStateNotifier extends StateNotifier<ArtistPostsState> {
  ArtistPostsStateNotifier({@required IPostRepository postRepository})
      : _postRepository = postRepository,
        super(ArtistPostsState.empty());

  final IPostRepository _postRepository;

  void getPostsFromArtists(String artistString) async {
    try {
      state = ArtistPostsState.loading();
      final artist =
          artistString.split(' ').map((e) => "~$e").toList().join(' ');
      final dtos = await _postRepository.getPosts(artist, 1, limit: 20);
      final posts = dtos.map((dto) => dto.toEntity()).toList();

      state = ArtistPostsState.fetched(posts: posts);
    } on Exception {
      state = ArtistPostsState.error();
    }
  }
}
