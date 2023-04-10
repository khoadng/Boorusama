// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/core/application/common.dart';

abstract class RelatedTagEvent extends Equatable {
  const RelatedTagEvent();
}

class RelatedTagRequested extends RelatedTagEvent {
  const RelatedTagRequested({
    required this.query,
  });

  final String query;

  @override
  List<Object> get props => [query];
}

class RelatedTagBloc extends Bloc<RelatedTagEvent, AsyncLoadState<RelatedTag>> {
  RelatedTagBloc({
    required RelatedTagRepository relatedTagRepository,
  }) : super(const AsyncLoadState.initial()) {
    on<RelatedTagRequested>(
      (event, emit) async {
        if (event.query.isEmpty) {
          emit(const AsyncLoadState.failure());

          return;
        }
        await tryAsync<RelatedTag>(
          action: () => relatedTagRepository.getRelatedTag(event.query),
          onLoading: () => emit(const AsyncLoadState.loading()),
          onFailure: (_, __) => emit(const AsyncLoadState.failure()),
          onSuccess: (tags) async {
            emit(AsyncLoadState.success(tags));
          },
        );
      },
      transformer: restartable(),
    );
  }
}
