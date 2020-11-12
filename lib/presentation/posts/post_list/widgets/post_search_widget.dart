import 'package:boorusama/application/tags/tag_suggestions/bloc/tag_suggestions_bloc.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/presentation/posts/post_list/models/tag_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class PostListSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearched;
  final Function onDownloadAllSelected;
  final FloatingSearchBarController controller;
  final Widget body;
  // final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

  PostListSearchBar(
      {Key key,
      @required this.onSearched,
      this.body,
      this.controller,
      this.onDownloadAllSelected});

  @override
  _PostListSearchBarState createState() => _PostListSearchBarState();
}

class _PostListSearchBarState extends State<PostListSearchBar> {
  TagSuggestionsBloc _tagSuggestionsBloc;
  List<Tag> _tags;
  TagQuery _tagQuery;

  @override
  void initState() {
    super.initState();
    _tagSuggestionsBloc = BlocProvider.of<TagSuggestionsBloc>(context);
    _tags = List<Tag>();
    _tagQuery = TagQuery(
      onTagInputCompleted: () => _tags.clear(),
      onCleared: () => widget.controller.close(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      hint: 'Search...',
      controller: widget.controller,
      onSubmitted: _handleSubmitted,
      body: widget.body,
      clearQueryOnClose: false,
      transitionDuration: const Duration(milliseconds: 150),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: 0.0,
      openAxisAlignment: 0.0,
      onQueryChanged: (query) {
        _tagQuery.update(query);

        _tagSuggestionsBloc.add(
            TagSuggestionsRequested(tagString: _tagQuery.currentTag, page: 1));
      },
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
          duration: Duration(milliseconds: 400),
        ),
        PopupMenuButton<PostListAction>(
          offset: Offset(0, 250), // Change location of the menu
          onSelected: (value) {
            switch (value) {
              case PostListAction.downloadAll:
                widget.onDownloadAllSelected();
                break;
              default:
            }
          },
          itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<PostListAction>>[
            const PopupMenuItem<PostListAction>(
              value: PostListAction.downloadAll,
              child: Text('Download all'),
            ),
          ],
        )
      ],
      builder: (context, transition) => buildExpandableBody(),
    );
  }

  Widget buildExpandableBody() {
    return BlocListener<TagSuggestionsBloc, TagSuggestionsState>(
      listener: (context, state) {
        if (state is TagSuggestionsLoaded) {
          setState(() {
            _tags = state.tags;
          });
        } else {
          //TODO: handle other case here;
        }
      },
      child: SuggestionItems(
        tags: _tags,
        widget: widget,
        onItemTap: (value) {
          _tagQuery.add(value);
          widget.controller.query = _tagQuery.currentQuery;
        },
      ),
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

class SuggestionItems extends StatelessWidget {
  const SuggestionItems({
    Key key,
    @required List<Tag> tags,
    @required this.widget,
    @required this.onItemTap,
  })  : _tags = tags,
        super(key: key);

  final List<Tag> _tags;
  final PostListSearchBar widget;
  final ValueChanged<String> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4.0,
      borderRadius: BorderRadius.circular(8),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _tags.length > 6 ? 6 : _tags.length,
        padding: EdgeInsets.all(0.0),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () => onItemTap(_tags[index].rawName),
            trailing: Text(_tags[index].postCount.toString(),
                style: TextStyle(color: Colors.grey)),
            title: Text(
              _tags[index].displayName,
              style: TextStyle(color: Color(_tags[index].tagHexColor)),
            ),
          );
        },
      ),
    );
  }
}

enum PostListAction { downloadAll }
