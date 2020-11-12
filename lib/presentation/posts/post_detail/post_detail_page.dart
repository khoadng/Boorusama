import 'package:boorusama/application/posts/post_favorites/bloc/post_favorites_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/posts/post_name.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/presentation/comments/comment_page.dart';
import 'package:boorusama/presentation/posts/post_detail/widgets/post_tag_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PostDetailPage extends StatelessWidget {
  final Post post;
  final String postHeroTag;
  final List<Tag> tags;

  const PostDetailPage({
    Key key,
    @required this.post,
    @required this.tags,
    @required this.postHeroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appbarActions = <Widget>[];

    appbarActions.add(
      RaisedButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.red)),
        onPressed: () {},
        color: Colors.red,
        textColor: Colors.white,
        child: Text("Favorite".toUpperCase(), style: TextStyle(fontSize: 14)),
      ),
    );

    return Stack(
      children: [
        PostTagList(tags: tags),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 16.0, bottom: 10.0, left: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "${post.name.characterOnly.pretty.capitalizeFirstofEach}",
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.subtitle1),
                    Text(
                        "${post.name.copyRightOnly.pretty.capitalizeFirstofEach}",
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.caption),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ButtonBar(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.favorite),
                    onPressed: () =>
                        BlocProvider.of<PostFavoritesBloc>(context).add(
                      AddToFavorites(post.id),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.comment),
                    onPressed: () {
                      showBarModalBottomSheet(
                        expand: false,
                        context: context,
                        builder: (context, controller) => CommentPage(
                          postId: post.id,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
