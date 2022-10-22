// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/wikis/wikis.dart';

class WikiState extends Equatable {
  const WikiState({
    required this.wiki,
  });

  factory WikiState.initial() => const WikiState(wiki: null);

  final Wiki? wiki;

  WikiState copyWith({
    Wiki? wiki,
  }) =>
      WikiState(
        wiki: wiki,
      );

  @override
  List<Object?> get props => [wiki];
}

abstract class WikiEvent extends Equatable {
  const WikiEvent();
}

class WikiFetched extends WikiEvent {
  const WikiFetched({
    required this.tag,
  });

  final String tag;

  @override
  List<Object?> get props => [tag];
}

class WikiBloc extends Bloc<WikiEvent, WikiState> {
  WikiBloc({
    required WikiRepository wikiRepository,
  }) : super(WikiState.initial()) {
    on<WikiFetched>((event, emit) async {
      await tryAsync<Wiki?>(
        action: () => wikiRepository.getWikiFor(event.tag),
        // onLoading: () => emit(loading),
        // onFailure: (error, stackTrace) => emit(error),
        onSuccess: (data) async {
          emit(state.copyWith(wiki: data));
        },
      );
    });
  }
}
