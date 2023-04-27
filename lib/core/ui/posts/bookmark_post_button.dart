// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/core/application/bookmarks.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/domain/posts.dart';

class BookmarkPostButton extends StatelessWidget {
  const BookmarkPostButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (context, state) {
        return BlocBuilder<BookmarkCubit, BookmarkState>(
          builder: (context, bookmarkState) {
            final isBookmarked =
                bookmarkState.isBookmarked(post, state.booru!.booruType);

            return isBookmarked
                ? IconButton(
                    onPressed: () {
                      context.read<BookmarkCubit>().removeBookmark(
                            bookmarkState.getBookmark(
                                post, state.booru!.booruType)!,
                          );
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.solidBookmark,
                      color: Colors.red,
                    ),
                  )
                : IconButton(
                    onPressed: () {
                      context.read<BookmarkCubit>().addBookmark(
                            "",
                            state.booru!,
                            post,
                          );
                    },
                    icon: const FaIcon(FontAwesomeIcons.bookmark),
                  );
          },
        );
      },
    );
  }
}
