// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/i_favorite_post_repository.dart';

class IsPostFavoritedCubit extends Cubit<AsyncLoadState<bool>> {
  IsPostFavoritedCubit({
    required this.accountRepository,
    required this.favoritePostRepository,
  }) : super(AsyncLoadState.initial());

  final IAccountRepository accountRepository;
  final IFavoritePostRepository favoritePostRepository;

  void checkIfFavorited(int postId) {
    TryAsync<bool>(
      action: () async {
        final account = await accountRepository.get();
        final isFaved =
            favoritePostRepository.checkIfFavoritedByUser(account.id, postId);

        return isFaved;
      },
      onLoading: () => emit(AsyncLoadState.loading()),
      onFailure: (stackTrace, error) => emit(AsyncLoadState.failure()),
      onSuccess: (value) => emit(AsyncLoadState.success(value)),
    );
  }
}
