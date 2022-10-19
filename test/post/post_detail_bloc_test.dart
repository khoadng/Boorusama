// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/scaffolding.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_detail_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/autocompletes/autocomplete.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  group('[post detail test]', () {
    final postRepo = MockPostRepository();
    blocTest<PostDetailBloc, PostDetailState>(
      'add new tag',
      setUp: () {
        when(() => postRepo.putTag(any(), any()))
            .thenAnswer((invocation) async => true);
      },
      tearDown: () => reset(postRepo),
      build: () => PostDetailBloc(
        initialIndex: 0,
        postRepository: postRepo,
        tags: [
          PostDetailTag(
            name: 'foo',
            category: TagAutocompleteCategory.general(),
            postId: 1,
          )
        ],
        posts: [
          PostData(post: Post.empty().copyWith(id: 1), isFavorited: false),
        ],
        onPostUpdated: (_, __, ___) {},
        idGenerator: () => 1,
      ),
      act: (bloc) => bloc
          .add(const PostDetailTagUpdated(tag: 'bar', category: 1, postId: 1)),
      expect: () => [
        PostDetailState.initial().copyWith(
          id: 1,
          currentIndex: 0,
          currentPost:
              PostData(post: Post.empty().copyWith(id: 1), isFavorited: false),
          tags: [
            PostDetailTag(
              name: 'bar',
              category: TagAutocompleteCategory.artist(),
              postId: 1,
            ),
            PostDetailTag(
              name: 'foo',
              category: TagAutocompleteCategory.general(),
              postId: 1,
            ),
          ],
        )
      ],
    );

    blocTest<PostDetailBloc, PostDetailState>(
      'index changed',
      build: () => PostDetailBloc(
        initialIndex: 0,
        postRepository: postRepo,
        tags: [],
        posts: [
          PostData(post: Post.empty().copyWith(id: 1), isFavorited: false),
          PostData(post: Post.empty().copyWith(id: 2), isFavorited: false),
        ],
        onPostUpdated: (_, __, ___) {},
        idGenerator: () => 1,
      ),
      act: (bloc) => bloc.add(const PostDetailIndexChanged(index: 1)),
      expect: () => [
        PostDetailState.initial().copyWith(
          currentIndex: 1,
          currentPost:
              PostData(post: Post.empty().copyWith(id: 2), isFavorited: false),
        )
      ],
    );

    blocTest<PostDetailBloc, PostDetailState>(
      'mode changed',
      build: () => PostDetailBloc(
        initialIndex: 0,
        postRepository: postRepo,
        tags: [],
        posts: [
          PostData(post: Post.empty().copyWith(id: 1), isFavorited: false),
        ],
        onPostUpdated: (_, __, ___) {},
        idGenerator: () => 1,
      ),
      act: (bloc) =>
          bloc.add(const PostDetailModeChanged(enableSlideshow: true)),
      expect: () => [
        PostDetailState.initial().copyWith(
          currentIndex: 0,
          enableSlideShow: true,
          currentPost:
              PostData(post: Post.empty().copyWith(id: 1), isFavorited: false),
        )
      ],
    );

    blocTest<PostDetailBloc, PostDetailState>(
      'slide show config changed',
      build: () => PostDetailBloc(
        initialIndex: 0,
        postRepository: postRepo,
        tags: [],
        posts: [
          PostData(post: Post.empty().copyWith(id: 1), isFavorited: false),
        ],
        onPostUpdated: (_, __, ___) {},
        idGenerator: () => 1,
      ),
      act: (bloc) => bloc.add(PostDetailSlideShowConfigChanged(
          config: bloc.state.slideShowConfig.copyWith(skipAnimation: true))),
      expect: () => [
        PostDetailState.initial().copyWith(
          currentIndex: 0,
          slideShowConfig: PostDetailState.initial()
              .slideShowConfig
              .copyWith(skipAnimation: true),
          currentPost:
              PostData(post: Post.empty().copyWith(id: 1), isFavorited: false),
        )
      ],
    );
  });
}
