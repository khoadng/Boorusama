// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/recommended/recommended.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
import '../models/parent_child_data.dart';
import 'information_section.dart';
import 'parent_child_tile.dart';
import 'post_action_toolbar.dart';
import 'recommend_section.dart';
import 'recommend_section_placeholder.dart';

class InformationAndRecommended extends StatelessWidget {
  const InformationAndRecommended({
    Key? key,
    required this.post,
    required this.actionBarDisplayBehavior,
    required this.imagePath,
    required this.screenSize,
  }) : super(key: key);

  final Post post;
  final ActionBarDisplayBehavior actionBarDisplayBehavior;
  final ValueNotifier<String?> imagePath;
  final ScreenSize screenSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InformationSection(post: post),
        if (actionBarDisplayBehavior == ActionBarDisplayBehavior.scrolling)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ActionBar(
              imagePath: imagePath,
              post: post,
            ),
          ),
        if (post.hasParentOrChildren)
          ParentChildTile(data: getParentChildData(post)),
        if (!post.hasBothParentAndChildren)
          const Divider(height: 8, thickness: 1),
        _buildRecommendedArtistList(post),
        _buildRecommendedCharacterList(post),
      ],
    );
  }

  Widget _buildRecommendedArtistList(Post post) {
    if (post.artistTags.isEmpty) return const SizedBox.shrink();
    return BlocBuilder<RecommendedArtistPostCubit,
        AsyncLoadState<List<Recommended>>>(
      builder: (context, state) {
        if (state.status == LoadStatus.success) {
          final recommendedItems = state.data!;

          if (recommendedItems.isEmpty) return const SizedBox.shrink();

          return Column(
            children: recommendedItems
                .map((item) => _buildRecommendPostSection(
                      item,
                      '/artist',
                      post,
                    ))
                .toList(),
          );
        } else {
          final artists = post.artistTags;
          return Column(
            children: [
              ...List.generate(
                artists.length,
                (index) => RecommendSectionPlaceHolder(
                  itemCount: screenSize == ScreenSize.large ? 9 : 6,
                  header: ListTile(
                    title: Text(artists[index].removeUnderscoreWithSpace()),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                  ),
                ),
              )
            ],
          );
        }
      },
    );
  }

  Widget _buildRecommendedCharacterList(Post post) {
    if (post.characterTags.isEmpty) return const SizedBox.shrink();
    return BlocBuilder<RecommendedCharacterPostCubit,
        AsyncLoadState<List<Recommended>>>(
      builder: (context, state) {
        if (state.status == LoadStatus.success) {
          final recommendedItems = state.data!;

          if (recommendedItems.isEmpty) return const SizedBox.shrink();

          return Column(
            children: recommendedItems
                .map((item) => _buildRecommendPostSection(
                      item,
                      '/character',
                      post,
                    ))
                .toList(),
          );
        } else {
          final characters = post.characterTags;
          return Column(
            children: [
              ...List.generate(
                characters.length,
                (index) => RecommendSectionPlaceHolder(
                  itemCount: screenSize == ScreenSize.large ? 9 : 6,
                  header: ListTile(
                    title: Text(characters[index].removeUnderscoreWithSpace()),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                  ),
                ),
              )
            ],
          );
        }
      },
    );
  }

  Widget _buildRecommendPostSection(
    Recommended item,
    String url,
    Post post,
  ) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return RecommendPostSection(
          imageQuality: state.settings.imageQuality,
          header: ListTile(
            onTap: () => AppRouter.router.navigateTo(
              context,
              url,
              routeSettings: RouteSettings(
                arguments: [
                  item.tag,
                  post.normalImageUrl,
                ],
              ),
            ),
            title: Text(item.title),
            trailing: const Icon(Icons.keyboard_arrow_right_rounded),
          ),
          posts: item.posts,
        );
      },
    );
  }
}

class ActionBar extends StatelessWidget {
  const ActionBar({
    Key? key,
    required this.imagePath,
    required this.post,
  }) : super(key: key);

  final ValueNotifier<String?> imagePath;
  final Post post;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: imagePath,
      builder: (context, value, child) => PostActionToolbar(
        post: post,
        imagePath: value,
      ),
    );
  }
}
