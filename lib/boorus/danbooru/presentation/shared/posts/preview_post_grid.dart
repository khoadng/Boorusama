// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/api/api_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/is_post_favorited.dart';
import 'package:boorusama/boorus/danbooru/application/recommended/recommended_post_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/i_favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_detail_page.dart';
import 'package:boorusama/core/presentation/widgets/slide_in_route.dart';

class PreviewPostGrid extends StatelessWidget {
  const PreviewPostGrid({
    Key? key,
    required this.posts,
    this.physics,
  }) : super(key: key);

  final List<Post> posts;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    void handleTap(Post post, int index) {
      Navigator.of(context).push(
        SlideInRoute(
          pageBuilder: (context, _, __) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => IsPostFavoritedCubit(
                  accountRepository:
                      RepositoryProvider.of<IAccountRepository>(context),
                  favoritePostRepository:
                      RepositoryProvider.of<IFavoritePostRepository>(context),
                ),
              ),
              BlocProvider(
                  create: (context) => RecommendedArtistPostCubit(
                      postRepository:
                          RepositoryProvider.of<IPostRepository>(context))),
              BlocProvider(
                  create: (context) => RecommendedCharacterPostCubit(
                      postRepository:
                          RepositoryProvider.of<IPostRepository>(context))),
              BlocProvider.value(
                  value: BlocProvider.of<AuthenticationCubit>(context)),
              BlocProvider.value(
                  value: BlocProvider.of<ApiEndpointCubit>(context)),
            ],
            child: RepositoryProvider.value(
              value: RepositoryProvider.of<ITagRepository>(context),
              child: PostDetailPage(
                post: post,
                intitialIndex: index,
                posts: posts,
                onExit: (currentIndex) => {},
                onPostChanged: (index) => {},
              ),
            ),
          ),
          transitionDuration: const Duration(milliseconds: 150),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      shrinkWrap: true,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: posts.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(3.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: GestureDetector(
            onTap: () => handleTap(posts[index], index),
            child: CachedNetworkImage(
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width * 0.3,
              fit: BoxFit.cover,
              imageUrl: posts[index].previewImageUri.toString(),
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
