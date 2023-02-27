// Flutter imports:
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
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
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
              child: Divider(),
            ),
            if (state.favorites != null)
              if (state.favorites!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const ListTile(
                        title: Text('Favorites'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(
                          height: 160,
                          child: ListView.builder(
                            itemCount: state.favorites!.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final post = state.favorites![index];

                              return Padding(
                                padding: const EdgeInsets.all(4),
                                child: BooruImage(
                                  imageUrl: post.thumbnailImageUrl,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
            if (state.uploads != null)
              if (state.uploads!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const ListTile(
                        title: Text('Uploads'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(
                          height: 160,
                          child: ListView.builder(
                            itemCount: state.uploads!.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final post = state.uploads![index];

                              return Padding(
                                padding: const EdgeInsets.all(4),
                                child: BooruImage(
                                  imageUrl: post.thumbnailImageUrl,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
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
