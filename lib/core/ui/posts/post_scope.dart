// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';

typedef PostFetcher = PostsOrError Function(int page);

mixin PostFetcherMixin<T extends StatefulWidget> on State<T> {
  PostFetcher get fetcher;

  BooruError? errors;

  Future<List<Post>> fetchPosts(int page) =>
      fetcher(page).run().then((value) => value.fold(
            (l) {
              setState(() => errors = l);
              return <Post>[];
            },
            (r) => r,
          ));
}

class PostScope extends StatefulWidget {
  const PostScope({
    super.key,
    required this.fetcher,
    required this.builder,
  });

  final PostFetcher fetcher;
  final Widget Function(
    BuildContext context,
    PostGridController<Post> controller,
    BooruError? errors,
  ) builder;

  @override
  State<PostScope> createState() => _PostScopeState();
}

class _PostScopeState extends State<PostScope> with PostFetcherMixin {
  late final _controller = PostGridController<Post>(
    fetcher: (page) => fetchPosts(page),
    refresher: () => fetchPosts(1),
    pageMode: context
                .read<SettingsCubit>()
                .state
                .settings
                .contentOrganizationCategory ==
            ContentOrganizationCategory.infiniteScroll
        ? PageMode.infinite
        : PageMode.paginated,
  );

  @override
  PostFetcher get fetcher => widget.fetcher;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        _controller.setPageMode(state.settings.contentOrganizationCategory ==
                ContentOrganizationCategory.infiniteScroll
            ? PageMode.infinite
            : PageMode.paginated);
      },
      child: widget.builder(
        context,
        _controller,
        errors,
      ),
    );
  }
}
