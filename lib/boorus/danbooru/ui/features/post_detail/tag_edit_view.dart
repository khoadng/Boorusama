// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/ui/features/tags/tags.dart';
import 'package:boorusama/core/application/theme/theme.dart';
import 'package:boorusama/core/ui/search_bar.dart';
import 'package:boorusama/core/ui/warning_container.dart';
import 'simple_tag_search_view.dart';

class TagEditView extends StatelessWidget {
  const TagEditView({
    super.key,
    required this.post,
    required this.tags,
    this.recommendedTotalOfTag = 20,
  });

  final Post post;
  final List<PostDetailTag> tags;
  final int recommendedTotalOfTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit tags'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: WarningContainer(
                    contentBuilder: (context) => const Text(
                      'Before editing, read the how to tag guide.',
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tags',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text('${tags.length}/$recommendedTotalOfTag'),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Divider(
                    thickness: 2,
                  ),
                ),
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ListTile(
                            title: Text(
                              tags[index].name.replaceAll('_', ' '),
                              style: TextStyle(
                                color: getTagColor(
                                  stringToTagCategory(tags[index].category),
                                  themeState.theme,
                                ),
                              ),
                            ),
                            // trailing: IconButton(
                            //   onPressed: null,
                            //   icon: const FaIcon(FontAwesomeIcons.xmark),
                            // ),
                          );
                        },
                        childCount: tags.length,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: SearchBar(
              enabled: false,
              hintText: 'Add tag',
              onTap: () {
                final bloc = context.read<PostDetailBloc>();
                showBarModalBottomSheet(
                  context: context,
                  builder: (context) => SimpleTagSearchView(
                    onSelected: (tag) {
                      bloc.add(PostDetailTagUpdated(
                        tag: tag.value,
                        category: tag.category,
                        postId: post.id,
                      ));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
