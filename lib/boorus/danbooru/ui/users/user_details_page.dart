// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/users.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'user_level_colors.dart';

class UserDetailsPage extends StatelessWidget {
  const UserDetailsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserBloc>().state;

    return Scaffold(
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _UserInfoBox(user: user),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 12),
            ),
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatsButton(
                        num: user.uploadCount,
                        title: 'Uploads',
                      ),
                      const SizedBox(height: 12),
                      _StatsButton(
                        num: user.favoriteGroupCount,
                        title: 'Favgroups',
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatsButton(
                        num: user.tagEditCount,
                        title: 'Tag edits',
                      ),
                      const SizedBox(height: 12),
                      _StatsButton(
                        num: user.commentCount,
                        title: 'Comments',
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatsButton(
                        num: user.noteEditCount,
                        title: 'Note edits',
                      ),
                      const SizedBox(height: 12),
                      _StatsButton(
                        num: user.forumPostCount,
                        title: 'Forum posts',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (state.uploads != null)
              if (state.uploads!.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Divider(
                    thickness: 2,
                    height: 26,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _PreviewList(
                    posts: state.uploads!,
                    onViewMore: () =>
                        goToSearchPage(context, tag: 'user:${user.name}'),
                    title: 'Uploads',
                  ),
                ),
              ],
            if (state.favorites != null)
              if (state.favorites!.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Divider(
                    thickness: 2,
                    height: 36,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _PreviewList(
                    posts: state.favorites!,
                    onViewMore: () =>
                        goToSearchPage(context, tag: 'ordfav:${user.name}'),
                    title: 'Favorites',
                  ),
                ),
              ],
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

class _UserInfoBox extends StatelessWidget {
  const _UserInfoBox({
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: user.level.toColor(),
                      ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Chip(
              label: Text(user.level.name.sentenceCase),
              visualDensity: const VisualDensity(vertical: -4),
              backgroundColor: user.level.toColor(),
            ),
          ],
        ),
        Text(
          DateFormat('yyyy-MM-dd').format(user.joinedDate),
          style: TextStyle(
            color: Theme.of(context).hintColor,
          ),
        ),
      ],
    );
  }
}

class _StatsButton extends StatelessWidget {
  const _StatsButton({
    required this.num,
    required this.title,
  });

  final int num;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          NumberFormat.compact().format(num),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        Text(
          title,
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      ],
    );
  }
}

class _PreviewList extends ConsumerWidget {
  const _PreviewList({
    required this.title,
    required this.posts,
    required this.onViewMore,
  });

  final String title;
  final List<DanbooruPost> posts;
  final void Function() onViewMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            height: 150,
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
                      posts: posts.toList(),
                      initialIndex: index,
                    ),
                    child: BooruImage(
                      borderRadius: BorderRadius.zero,
                      imageUrl: post.url720x720,
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
