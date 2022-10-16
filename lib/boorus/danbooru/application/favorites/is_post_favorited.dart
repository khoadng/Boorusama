// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorite_post_repository.dart';
import 'package:boorusama/common/bloc_stream_transformer.dart';

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
    required AccountRepository accountRepository,
    required FavoritePostRepository favoritePostRepository,
  }) : super(const AsyncLoadState.initial()) {
    on<IsPostFavoritedRequested>(
      (event, emit) async {
        final account = await accountRepository.get();
        if (account == Account.empty) {
          emit(const AsyncLoadState.success(false));
          return;
        }

        await tryAsync<bool>(
          action: () async {
            final isFaved = favoritePostRepository.checkIfFavoritedByUser(
                account.id, event.postId);

            return isFaved;
          },
          onLoading: () => emit(const AsyncLoadState.loading()),
          onFailure: (stackTrace, error) =>
              emit(const AsyncLoadState.failure()),
          onSuccess: (value) async => emit(AsyncLoadState.success(value)),
        );
      },
      transformer: debounceRestartable(const Duration(milliseconds: 150)),
    );
  }
}
