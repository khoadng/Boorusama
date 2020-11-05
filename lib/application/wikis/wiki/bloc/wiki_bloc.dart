import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/wikis/i_wiki_repository.dart';
import 'package:boorusama/domain/wikis/wiki.dart';
import 'package:equatable/equatable.dart';

part 'wiki_event.dart';
part 'wiki_state.dart';

class WikiBloc extends Bloc<WikiEvent, WikiState> {
  final IWikiRepository _wikiRepository;

  WikiBloc(this._wikiRepository) : super(WikiInitial());

  @override
  Stream<WikiState> mapEventToState(
    WikiEvent event,
  ) async* {
    if (event is WikiRequested) {
      yield WikiLoading();
      final wiki = await _wikiRepository.getWikiFor(event.title);
      yield WikiFetched(wiki);
    }
  }
}
