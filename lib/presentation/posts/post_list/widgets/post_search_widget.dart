import 'package:boorusama/application/tags/tag_suggestions/bloc/tag_suggestions_bloc.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class PostListSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearched;
  final FloatingSearchBarController controller;
  // final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

  PostListSearchBar({Key key, @required this.onSearched, this.controller});

  @override
  _PostListSearchBarState createState() => _PostListSearchBarState();
}

class _PostListSearchBarState extends State<PostListSearchBar> {
  TagSuggestionsBloc _tagSuggestionsBloc;
  List<Tag> _tags;

  @override
  void initState() {
    super.initState();
    _tagSuggestionsBloc = BlocProvider.of<TagSuggestionsBloc>(context);
    _tags = List<Tag>();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      hint: 'Search...',
      controller: widget.controller,
      onSubmitted: _handleSubmitted,
      clearQueryOnClose: false,
      transitionDuration: const Duration(milliseconds: 150),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: 0.0,
      openAxisAlignment: 0.0,
      debounceDelay: const Duration(milliseconds: 200),
      onQueryChanged: (query) {
        if (query.isEmpty) {
          widget.controller.close();
          return;
        }
        if (query.endsWith(" ")) {
          widget.controller.close();
          return;
        }
        setState(() {
          _tags.clear();
        });
        _tagSuggestionsBloc
            .add(TagSuggestionsRequested(tagString: query, page: 1));
      },
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
          duration: Duration(milliseconds: 400),
        ),
      ],
      builder: (context, transition) => buildExpandableBody(),
    );
  }

  Widget buildExpandableBody() {
    return BlocBuilder<TagSuggestionsBloc, TagSuggestionsState>(
        builder: (context, state) {
      if (state is TagSuggestionsLoaded) {
        _tags.addAll(state.tags);
        if (_tags.isNotEmpty) {
          return buildSuggestionItems(_tags);
        } else {
          return buildEmptySuggestions();
        }
      } else {
        return buildEmptySuggestions();
      }
    });
  }

  Material buildSuggestionItems(List<Tag> tags) {
    return Material(
        color: Colors.white,
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 6,
          padding: EdgeInsets.all(0.0),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () =>
                  widget.controller.query = _tags[index].displayName + " ",
              trailing: Text(tags[index].postCount.toString(),
                  style: TextStyle(color: Colors.grey)),
              title: Text(
                tags[index].displayName,
                style: TextStyle(color: Color(tags[index].tagHexColor)),
              ),
            );
          },
        ));
  }

  Material buildEmptySuggestions() {
    return Material(
      color: Colors.white,
      elevation: 4.0,
      borderRadius: BorderRadius.circular(8),
    );
  }

  void _handleSubmitted(String value) {
    widget.onSearched(value);
    setState(() {
      _tags.clear();
    });
    widget.controller.close();
  }
}
