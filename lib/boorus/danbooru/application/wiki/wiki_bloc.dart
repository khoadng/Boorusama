// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/wikis/wikis.dart';

class WikiState extends Equatable {
  const WikiState({
    required this.wiki,
    required this.status,
  });

  factory WikiState.initial() => const WikiState(
        wiki: null,
        status: LoadStatus.initial,
      );

  final Wiki? wiki;
  final LoadStatus status;

  WikiState copyWith({
    Wiki? Function()? wiki,
    LoadStatus? status,
  }) =>
      WikiState(
        wiki: wiki != null ? wiki() : this.wiki,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [wiki, status];
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
        onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
        onFailure: (error, stackTrace) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onSuccess: (data) async {
          emit(state.copyWith(
            status: LoadStatus.success,
            wiki: () => data,
          ));
        },
      );
    });
  }
}
