import 'package:boorusama/boorus/danbooru/domain/wikis/i_wiki_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/wikis/wiki.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/wikis/wiki_repository.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wiki_state.dart';
part 'wiki_state_notifier.freezed.dart';

class WikiStateNotifier extends StateNotifier<WikiState> {
  final IWikiRepository _wikiRepository;

  WikiStateNotifier(ProviderReference ref)
      : _wikiRepository = ref.read(wikiProvider),
        super(WikiState.initial());

  void getWiki(String subject) async {
    try {
      state = WikiState.loading();

      final wiki = await _wikiRepository.getWikiFor(subject);

      state = WikiState.fetched(wiki: wiki);
    } on Exception {
      state = WikiState.error(name: "Error", message: "Something went wrong");
    }
  }
}
