// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post_detail_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/danbooru/infra/services/tag_info_service.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'widgets/post_tag_list.dart';

class TagEditView extends StatelessWidget {
  const TagEditView({
    Key? key,
    required this.post,
    required this.tags,
  }) : super(key: key);

  final Post post;
  final List<PostDetailTag> tags;

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
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      WarningContainer(
                          contentBuilder: (context) => const Text(
                              'Before editing, read the how to tag guide.')),
                      SimplePostTagList(
                        tags: tags,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
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
                              category: tag.category?.getIndex(),
                              postId: post.id,
                            ));
                          },
                        ));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SimpleTagSearchView extends StatelessWidget {
  const SimpleTagSearchView({
    Key? key,
    required this.onSelected,
  }) : super(key: key);

  final void Function(AutocompleteData tag) onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TagSearchBloc(
        autocompleteRepository: context.read<AutocompleteRepository>(),
        tagInfo: context.read<TagInfo>(),
      ),
      child: BlocBuilder<TagSearchBloc, TagSearchState>(
        builder: (context, state) {
          final tags =
              state.suggestionTags.where((e) => e.category != null).toList();
          return Scaffold(
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: SearchBar(
                    autofocus: true,
                    onChanged: (value) {
                      context
                          .read<TagSearchBloc>()
                          .add(TagSearchChanged(value));
                    },
                  ),
                ),
                if (tags.isNotEmpty)
                  Expanded(
                    child: TagSuggestionItems(
                      tags: tags,
                      onItemTap: (tag) {
                        onSelected(tag);
                        Navigator.of(context).pop();
                      },
                      currentQuery: state.query,
                    ),
                  )
                else
                  const Expanded(
                    child: Center(
                      child: Text('Type something in search bar'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
