// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:hooks_riverpod/all.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/wikis/wiki.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/wikis/wiki_repository.dart';

final _wikiProvider =
    FutureProvider.autoDispose.family<Wiki, String>((ref, subject) async {
  final repo = ref.watch(wikiProvider);
  final wiki = await repo.getWikiFor(subject);

  ref.maintainState = true;

  return wiki;
});

class WikiPage extends HookWidget {
  final String title;

  const WikiPage({
    Key key,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wiki = useProvider(_wikiProvider(title));

    return Material(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Center(child: Text(title)),
          ),
          body: wiki.when(
              data: (wiki) => SingleChildScrollView(child: Text(wiki.body)),
              loading: () => Center(
                    child: CircularProgressIndicator(),
                  ),
              error: (obj, stackTrace) => Center(
                  child: Text(
                      "Something went wrong, or this wiki page may not exist."))),
        ),
      ),
    );
  }
}
