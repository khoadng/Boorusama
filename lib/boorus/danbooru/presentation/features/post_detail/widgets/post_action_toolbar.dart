// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/is_post_favorited.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/i_favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/comment/comment_page.dart';

class PostActionToolbar extends HookWidget {
  const PostActionToolbar({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      ReadContext(context)
          .read<IsPostFavoritedCubit>()
          .checkIfFavorited(post.id);
    }, []);

    final favCount = useState(post.favCount);

    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, state) =>
          ButtonBar(alignment: MainAxisAlignment.spaceEvenly, children: [
        if (state is Authenticated)
          BlocBuilder<IsPostFavoritedCubit, AsyncLoadState<bool>>(
            builder: (context, state) {
              if (state.status == LoadStatus.success) {
                final value = state.data!;
                final button = TextButton.icon(
                    onPressed: () async {
                      final result = value
                          ? RepositoryProvider.of<IFavoritePostRepository>(
                                  context)
                              .removeFromFavorites(post.id)
                          : RepositoryProvider.of<IFavoritePostRepository>(
                                  context)
                              .addToFavorites(post.id);

                      final success = await result;
                      ReadContext(context)
                          .read<IsPostFavoritedCubit>()
                          .checkIfFavorited(post.id);
                      print("operation success = $success");
                    },
                    icon: value
                        ? FaIcon(FontAwesomeIcons.solidHeart, color: Colors.red)
                        : FaIcon(
                            FontAwesomeIcons.heart,
                            color: Colors.white,
                          ),
                    label: Text(
                      favCount.value.toString(),
                      style: TextStyle(color: Colors.white),
                    ));
                return button;
              } else if (state.status == LoadStatus.failure) {
                return SizedBox.shrink();
              } else {
                return Center(
                  child: TextButton.icon(
                      onPressed: null,
                      icon: FaIcon(
                        FontAwesomeIcons.spinner,
                        color: Colors.white,
                      ),
                      label: Text(
                        post.favCount.toString(),
                        style: TextStyle(color: Colors.white),
                      )),
                );
              }
            },
          ),
        IconButton(
          onPressed: () => showBarModalBottomSheet(
            expand: false,
            context: context,
            builder: (context) => CommentPage(
              postId: post.id,
            ),
          ),
          icon: FaIcon(
            FontAwesomeIcons.comment,
            color: Colors.white,
          ),
        ),
      ]),
    );
  }
}
