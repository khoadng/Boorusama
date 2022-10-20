// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart' show parse;

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';

@immutable
class PoolDescriptionState extends Equatable {
  const PoolDescriptionState({
    required this.description,
    required this.descriptionEndpointRefUrl,
    required this.status,
  });

  factory PoolDescriptionState.initial() => const PoolDescriptionState(
        description: '',
        descriptionEndpointRefUrl: '',
        status: LoadStatus.initial,
      );

  final String description;
  final String descriptionEndpointRefUrl;
  final LoadStatus status;

  PoolDescriptionState copyWith({
    String? description,
    String? descriptionEndpointRefUrl,
    LoadStatus? status,
  }) =>
      PoolDescriptionState(
        description: description ?? this.description,
        descriptionEndpointRefUrl:
            descriptionEndpointRefUrl ?? this.descriptionEndpointRefUrl,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [description];
}

@immutable
abstract class PoolDescriptionEvent extends Equatable {
  const PoolDescriptionEvent();
}

class PoolDescriptionFetched extends PoolDescriptionEvent {
  const PoolDescriptionFetched({
    required this.poolId,
  }) : super();

  final PoolId poolId;

  @override
  List<Object?> get props => [poolId];
}

class PoolDescriptionBloc
    extends Bloc<PoolDescriptionEvent, PoolDescriptionState> {
  PoolDescriptionBloc({
    required PoolDescriptionRepository poolDescriptionRepository,
    required String endpoint,
  }) : super(PoolDescriptionState.initial()) {
    on<PoolDescriptionFetched>((event, emit) async {
      await tryAsync<String>(
        action: () => poolDescriptionRepository.getDescription(event.poolId),
        onFailure: (stackTrace, error) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
        onSuccess: (html) async {
          final description = htmlStringToDescriptionHtmlString(html);
          emit(description != null
              ? state.copyWith(
                  description: description,
                  descriptionEndpointRefUrl: endpoint,
                  status: LoadStatus.success,
                )
              : state.copyWith(
                  status: LoadStatus.failure,
                ));
        },
      );
    });
  }
}

String? htmlStringToDescriptionHtmlString(String htmlString) {
  final document = parse(htmlString);

  return document.getElementById('description')?.outerHtml;
}
