// Flutter imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/user/user_bloc.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';

class UserDetailsPage extends StatelessWidget {
  const UserDetailsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserBloc>().state;

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: _buildBody(context, user),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserState state) {
    final user = state.user;

    if (state.status == LoadStatus.success) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Chip(label: Text(user.level.name.sentenceCase)),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Member since '),
                        Text(
                          DateFormat('MMM dd, yyyy').format(user.joinedDate),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Divider(
                thickness: 2,
                height: 26,
              ),
            ),
            if (state.favorites != null)
              if (state.favorites!.isNotEmpty)
                SliverToBoxAdapter(
                  child: _PreviewList(
                    posts: state.favorites!,
                    onViewMore: () =>
                        goToSearchPage(context, tag: 'ordfav:${user.name}'),
                    title: 'Favorites',
                  ),
                )
              else
                const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
            const SliverToBoxAdapter(
              child: Divider(
                thickness: 2,
                height: 26,
              ),
            ),
            if (state.uploads != null)
              if (state.uploads!.isNotEmpty)
                SliverToBoxAdapter(
                  child: _PreviewList(
                    posts: state.uploads!,
                    onViewMore: () =>
                        goToSearchPage(context, tag: 'user:${user.name}'),
                    title: 'Uploads',
                  ),
                )
              else
                const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
          ],
        ),
      );
    } else if (state.status == LoadStatus.failure) {
      return const Center(
        child: Text('Fail to load profile'),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}

class _PreviewList extends StatelessWidget {
  const _PreviewList({
    required this.title,
    required this.posts,
    required this.onViewMore,
  });

  final String title;
  final List<Post> posts;
  final void Function() onViewMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          visualDensity: const VisualDensity(
            horizontal: -4,
            vertical: -4,
          ),
          trailing: TextButton(
            onPressed: onViewMore,
            child: const Text('View all'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            height: 160,
            child: ListView.builder(
              itemCount: posts.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final post = posts[index];

                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: GestureDetector(
                    onTap: () => goToDetailPage(
                      context: context,
                      posts: posts
                          .map((e) => PostData(
                                post: e,
                                isFavorited: false,
                                pools: const [],
                              ))
                          .toList(),
                      initialIndex: index,
                    ),
                    child: BooruImage(
                      borderRadius: BorderRadius.zero,
                      imageUrl: post.thumbnailImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
