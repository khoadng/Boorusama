import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/notes/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/application/theme/theme.dart';
import 'package:boorusama/core/domain/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class PostDetailPageProvider extends StatelessWidget {
  const PostDetailPageProvider({
    super.key,
    required this.authCubit,
    required this.tagBloc,
    required this.themeBloc,
    required this.noteRepo,
    required this.postRepo,
    required this.favRepo,
    required this.accountRepo,
    required this.postVoteRepo,
    required this.tags,
    required this.tagRepo,
    required this.posts,
    required this.initialIndex,
    required this.postBloc,
    required this.builder,
    required this.scrollController,
  });

  final AuthenticationCubit authCubit;
  final TagBloc tagBloc;
  final ThemeBloc themeBloc;
  final PostBloc? postBloc;
  final NoteRepository noteRepo;
  final PostRepository postRepo;
  final FavoritePostRepository favRepo;
  final AccountRepository accountRepo;
  final PostVoteRepository postVoteRepo;
  final List<PostDetailTag> tags;
  final TagRepository tagRepo;
  final List<PostData> posts;
  final int initialIndex;
  final Widget Function(int initialIndex, List<PostData> posts) builder;
  final AutoScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SettingsCubit, SettingsState, Settings>(
      selector: (state) => state.settings,
      builder: (context, settings) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => SliverPostGridBloc()),
            BlocProvider.value(value: authCubit),
            BlocProvider.value(value: tagBloc),
            BlocProvider.value(value: themeBloc),
            BlocProvider(
              create: (context) => PostDetailBloc(
                noteRepository: noteRepo,
                defaultDetailsStyle: settings.detailsDisplay,
                posts: posts,
                initialIndex: initialIndex,
                postRepository: postRepo,
                favoritePostRepository: favRepo,
                accountRepository: accountRepo,
                postVoteRepository: postVoteRepo,
                tags: tags,
                onPostChanged: (post) {
                  if (postBloc != null && !postBloc!.isClosed) {
                    postBloc!.add(PostUpdated(post: post));
                  }
                },
                tagCache: {},
              ),
            ),
          ],
          child: RepositoryProvider.value(
            value: tagRepo,
            child: Builder(
              builder: (context) =>
                  BlocListener<SliverPostGridBloc, SliverPostGridState>(
                listenWhen: (previous, current) =>
                    previous.nextIndex != current.nextIndex,
                listener: (context, state) {
                  if (scrollController == null) return;
                  scrollController!.scrollToIndex(
                    state.nextIndex,
                    duration: const Duration(milliseconds: 200),
                  );
                },
                child: builder(initialIndex, posts),
              ),
            ),
          ),
        );
      },
    );
  }
}
