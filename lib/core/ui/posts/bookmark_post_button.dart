// Flutter imports:
import 'package:boorusama/core/application/current_booru_notifier.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/core/application/bookmarks.dart';
import 'package:boorusama/core/domain/posts.dart';

class BookmarkPostButton extends ConsumerWidget {
  const BookmarkPostButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booru = ref.watch(currentBooruProvider);

    return BlocBuilder<BookmarkCubit, BookmarkState>(
      builder: (context, bookmarkState) {
        final isBookmarked = bookmarkState.isBookmarked(post, booru.booruType);

        return isBookmarked
            ? IconButton(
                onPressed: () {
                  context.read<BookmarkCubit>().removeBookmarkWithToast(
                        bookmarkState.getBookmark(post, booru.booruType)!,
                      );
                },
                icon: const FaIcon(
                  FontAwesomeIcons.solidBookmark,
                  color: Colors.red,
                ),
              )
            : IconButton(
                onPressed: () {
                  context.read<BookmarkCubit>().addBookmarkWithToast(
                        "",
                        booru,
                        post,
                      );
                },
                icon: const FaIcon(FontAwesomeIcons.bookmark),
              );
      },
    );
  }
}
