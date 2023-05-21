// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/core/application/boorus.dart';

final poolDescriptionProvider =
    NotifierProvider.family<PoolDescriptionNotifier, PoolDescriptionState, int>(
  PoolDescriptionNotifier.new,
  dependencies: [
    currentBooruProvider,
    poolDescriptionRepoProvider,
  ],
);

class PoolDescriptionNotifier
    extends FamilyNotifier<PoolDescriptionState, int> {
  @override
  PoolDescriptionState build(int arg) {
    fetch(arg);

    return PoolDescriptionState.initial();
  }

  Future<void> fetch(int poolId) async {
    final endpoint = ref.read(currentBooruProvider).url;
    final html =
        await ref.read(poolDescriptionRepoProvider).getDescription(poolId);
    final description = htmlStringToDescriptionHtmlString(html);

    state = state.copyWith(
      description: description,
      descriptionEndpointRefUrl: endpoint,
    );
  }
}

class PoolDescriptionState extends Equatable {
  const PoolDescriptionState({
    required this.description,
    required this.descriptionEndpointRefUrl,
  });

  factory PoolDescriptionState.initial() => const PoolDescriptionState(
        description: '',
        descriptionEndpointRefUrl: '',
      );

  final String description;
  final String descriptionEndpointRefUrl;

  PoolDescriptionState copyWith({
    String? description,
    String? descriptionEndpointRefUrl,
  }) =>
      PoolDescriptionState(
        description: description ?? this.description,
        descriptionEndpointRefUrl:
            descriptionEndpointRefUrl ?? this.descriptionEndpointRefUrl,
      );

  @override
  List<Object?> get props => [description];
}

String? htmlStringToDescriptionHtmlString(String htmlString) {
  final document = parse(htmlString);

  return document.getElementById('description')?.outerHtml;
}
