import 'package:boorusama/application/accounts/get_all_accounts/bloc/get_all_accounts_bloc.dart';
import 'package:boorusama/application/tags/tag_suggestions/bloc/tag_suggestions_bloc.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/presentation/accounts/account_info/account_info_page.dart';
import 'package:boorusama/presentation/accounts/add_account/add_account_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  GetAllAccountsBloc _getAllAccountsBloc;
  List<Tag> _tags;

  @override
  void initState() {
    super.initState();
    _tagSuggestionsBloc = BlocProvider.of<TagSuggestionsBloc>(context);
    _getAllAccountsBloc = BlocProvider.of<GetAllAccountsBloc>(context);
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
      onQueryChanged: (query) {
        if (query.isEmpty) {
          widget.controller.close();
          return;
        }
        if (query.endsWith(" ")) {
          widget.controller.close();
          return;
        }

        _tagSuggestionsBloc
            .add(TagSuggestionsRequested(tagString: query, page: 1));
      },
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
          duration: Duration(milliseconds: 400),
        ),
        BlocListener<GetAllAccountsBloc, GetAllAccountsState>(
          listener: (context, state) {
            if (state is GetAllAccountsSuccess) {
              if (state.accounts == null || state.accounts.isEmpty) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AddAccountPage()));
              } else {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        AccountInfoPage(accounts: state.accounts)));
              }
            }
          },
          child: GestureDetector(
            onTap: () => _getAllAccountsBloc.add(GetAllAccountsRequested()),
            child: CircleAvatar(
              radius: 18.0,
              backgroundColor: Colors.blue,
              child: Text("DK"),
            ),
          ),
        ),
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
      child: SuggestionItems(tags: _tags, widget: widget),
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
  })  : _tags = tags,
        super(key: key);

  final List<Tag> _tags;
  final PostListSearchBar widget;

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
              onTap: () =>
                  widget.controller.query = _tags[index].displayName + " ",
              trailing: Text(_tags[index].postCount.toString(),
                  style: TextStyle(color: Colors.grey)),
              title: Text(
                _tags[index].displayName,
                style: TextStyle(color: Color(_tags[index].tagHexColor)),
              ),
            );
          },
        ));
  }
}
