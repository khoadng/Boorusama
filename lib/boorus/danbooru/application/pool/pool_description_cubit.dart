// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart' show parse;

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/pool/pool.dart';

@immutable
class PoolDescriptionState extends Equatable {
  const PoolDescriptionState({
    required this.description,
    required this.descriptionEndpointRefUrl,
  });

  final String description;
  final String descriptionEndpointRefUrl;

  @override
  List<Object?> get props => [description];
}

class PoolDescriptionCubit extends Cubit<AsyncLoadState<PoolDescriptionState>> {
  PoolDescriptionCubit({
    required this.endpoint,
  }) : super(const AsyncLoadState.initial());

  final String endpoint;

  void getDescription(PoolId id) {
    tryAsync<String>(
        action: () =>
            Dio().get('${endpoint}pools/$id').then((value) => value.data),
        onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
        onLoading: () => emit(const AsyncLoadState.loading()),
        onSuccess: (html) async {
          final description = htmlStringToDescriptionHtmlString(html);
          emit(description != null
              ? AsyncLoadState.success(PoolDescriptionState(
                  description: description,
                  descriptionEndpointRefUrl: endpoint,
                ))
              : const AsyncLoadState.failure());
        });
  }
}

String? htmlStringToDescriptionHtmlString(String htmlString) {
  final document = parse(htmlString);
  return document.getElementById('description')?.outerHtml;
}
