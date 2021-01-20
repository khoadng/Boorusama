import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/search/suggestions_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';

class TagSettingsPage extends HookWidget {
  TagSettingsPage({
    Key key,
    @required this.settings,
  }) : super(key: key);

  final Setting settings;

  @override
  Widget build(BuildContext context) {
    final blackListedTags = useProvider(blacklistedTagsProvider);

    return blackListedTags.when(
      data: (tags) => Scaffold(
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () async {
        //     final tag = await showSearch(
        //       context: context,
        //       delegate: _Search(),
        //     );
        //     if (tag != null) {
        //       tags.add(tag);
        //     }
        //   },
        //   child: Icon(
        //     Icons.add,
        //   ),
        // ),
        appBar: AppBar(
          title: Text("Blacklisted tags"),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(tags[index]),
              trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  tags.remove(tags[index]);
                },
              ),
            );
          },
          itemCount: tags.length,
        ),
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: CircularProgressIndicator()),
    );
  }
}

final blacklistedTagsSuggestionProvider =
    StateNotifierProvider<SuggestionsStateNotifier>((ref) {
  return SuggestionsStateNotifier(ref);
});

class _Search extends SearchDelegate {
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
    if (query.isNotEmpty) {
      Future.delayed(
          Duration.zero,
          () => context
              .read(blacklistedTagsSuggestionProvider)
              .getSuggestions(query));

      return Consumer(
        builder: (context, watch, child) =>
            watch(blacklistedTagsSuggestionProvider.state).when(
          empty: () => Center(
            child: Text("Such empty"),
          ),
          loading: () => Center(
            child: CircularProgressIndicator(),
          ),
          fetched: (tags) => ListView.builder(
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              return ListTile(
                title: Text(tag.displayName),
                trailing: Text(tag.postCount.toString()),
                onTap: () {
                  close(context, tag.rawName);
                },
              );
            },
          ),
          error: (name, message) => Text(message),
        ),
      );
    } else {
      return Center(child: Text("Such empty"));
    }
  }
}
