import 'package:boorusama/application/wiki/wiki_state_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';

final wikiStateNotifierProvider =
    StateNotifierProvider<WikiStateNotifier>((ref) => WikiStateNotifier(ref));

class WikiPage extends StatefulWidget {
  final String title;

  const WikiPage({
    Key key,
    @required this.title,
  }) : super(key: key);

  @override
  _WikiPageState createState() => _WikiPageState();
}

class _WikiPageState extends State<WikiPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero,
        () => context.read(wikiStateNotifierProvider).getWiki(widget.title));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Center(child: Text(widget.title)),
          ),
          body: Consumer(
            builder: (context, watch, child) {
              final state = watch(wikiStateNotifierProvider.state);
              return state.when(
                initial: () => Center(child: CircularProgressIndicator()),
                loading: () => Center(child: CircularProgressIndicator()),
                fetched: (wiki) =>
                    SingleChildScrollView(child: Text(wiki.body)),
                error: (name, message) => Center(
                  child: Text(message),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
