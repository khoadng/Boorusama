import 'package:boorusama/application/tags/tag_suggestions/bloc/tag_suggestions_bloc.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/presentation/posts/post_list/models/tag_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'tag_suggestion_items.dart';

class PostSearch extends SearchDelegate {
  final ValueChanged<String> onSearched;
  List<Tag> _tags;
  TagQuery _tagQuery;

  PostSearch({
    @required this.onSearched,
    TextStyle searchFieldStyle,
  }) : super(searchFieldStyle: searchFieldStyle) {
    _tags = List<Tag>();
    _tagQuery = TagQuery(
      onTagInputCompleted: () => _tags.clear(),
      onCleared: null,
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () => query = "",
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _tagQuery.update(query);

    if (query.isNotEmpty) {
      BlocProvider.of<TagSuggestionsBloc>(context)
          .add(TagSuggestionsChanged(tagString: _tagQuery.currentTag, page: 1));

      return BlocBuilder<TagSuggestionsBloc, TagSuggestionsState>(
        builder: (context, state) {
          if (state is TagSuggestionsLoaded) {
            return Stack(children: <Widget>[
              TagSuggestionItems(
                  tags: state.tags,
                  onItemTap: (tag) => _onTagItemSelected(tag)),
              Positioned(
                bottom: 30.0,
                right: 30.0,
                child: FloatingActionButton(
                  onPressed: () => _submit(context, query),
                  child: Icon(Icons.search),
                ),
              )
            ]);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    } else {
      return Center(
        child: Text("Such empty"),
      );
    }
  }

  void _submit(BuildContext context, String value) {
    onSearched(value);
    context.read<TagSuggestionsBloc>().add(TagSuggestionsCleared());
    close(context, value);
  }

  void _onTagItemSelected(String tag) {
    _tagQuery.add(tag);
    query = _tagQuery.currentQuery;
  }
}
