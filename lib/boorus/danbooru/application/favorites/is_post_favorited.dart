// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/i_favorite_post_repository.dart';

@immutable
abstract class IsPostFavoritedEvent extends Equatable {
  const IsPostFavoritedEvent();
}

class IsPostFavoritedRequested extends IsPostFavoritedEvent {
  const IsPostFavoritedRequested({
    required this.postId,
  });
  final int postId;
  @override
  List<Object?> get props => [postId];
}

class IsPostFavoritedBloc
    extends Bloc<IsPostFavoritedEvent, AsyncLoadState<bool>> {
  IsPostFavoritedBloc({
    required IAccountRepository accountRepository,
    required IFavoritePostRepository favoritePostRepository,
  }) : super(const AsyncLoadState.initial()) {
    on<IsPostFavoritedRequested>(
      (event, emit) => tryAsync<bool>(
        action: () async {
          final account = await accountRepository.get();
          final isFaved = favoritePostRepository.checkIfFavoritedByUser(
              account.id, event.postId);

          return isFaved;
        },
        onLoading: () => emit(const AsyncLoadState.loading()),
        onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
        onSuccess: (value) => emit(AsyncLoadState.success(value)),
      ),
      transformer: restartable(),
    );
  }
}
