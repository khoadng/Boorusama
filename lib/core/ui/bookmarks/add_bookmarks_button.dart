// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/bookmarks.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/domain/posts.dart';

class AddBookmarksButton extends StatelessWidget {
  const AddBookmarksButton({
    super.key,
    required this.posts,
    required this.onPressed,
  });

  final List<Post> posts;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (context, state) {
        return IconButton(
          onPressed: posts.isNotEmpty
              ? () async {
                  context.read<BookmarkCubit>().addBookmarksWithToast(
                        state.booru!,
                        posts,
                      );
                  onPressed();
                }
              : null,
          icon: const Icon(Icons.bookmark_add),
        );
      },
    );
  }
}
