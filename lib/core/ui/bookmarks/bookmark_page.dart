// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import 'package:boorusama/core/application/bookmarks/bookmark_cubit.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/booru_image.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks'),
      ),
      body: BlocBuilder<BookmarkCubit, BookmarkState>(
        builder: (context, state) {
          switch (state.status) {
            case BookmarkStatus.loading:
              return Center(child: CircularProgressIndicator());
            case BookmarkStatus.success:
              return CustomScrollView(
                slivers: [
                  SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childCount: state.bookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = state.bookmarks[index];

                      return GestureDetector(
                        onTap: () => goToBookmarkDetailsPage(
                          context: context,
                          bookmarks: state.bookmarks,
                          initialIndex: index,
                        ),
                        child: BooruImage(
                          aspectRatio: bookmark.aspectRatio,
                          fit: BoxFit.cover,
                          imageUrl: bookmark.sampleUrl,
                          placeholderUrl: bookmark.thumbnailUrl,
                        ),
                      );
                    },
                  )
                ],
              );
            case BookmarkStatus.failure:
              return Center(child: Text(state.error));
            default:
              return Container();
          }
        },
      ),
    );
  }
}
