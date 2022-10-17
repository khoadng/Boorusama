// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/profiles/profiles.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit({
    required this.accountRepository,
    required this.profileRepository,
  }) : super(AuthenticationInitial());

  final AccountRepository accountRepository;
  final ProfileRepository profileRepository;

  Future<void> logIn([String username = '', String password = '']) async {
    if (state is AuthenticationInitial) {
      final account = await accountRepository.get();
      if (account != Account.empty) {
        emit(Authenticated(account: account));
      } else {
        emit(Unauthenticated());
      }
    } else if (state is Authenticated) {
      // Do nothing
    } else if (state is AuthenticationInProgress) {
      // Do nothing
    } else {
      try {
        emit(AuthenticationInProgress());
        final profile = await profileRepository.getProfile(
            username: username, apiKey: password);
        final account = Account.create(username, password, profile!.id);

        emit(Authenticated(account: account));
      } on InvalidUsernameOrPassword catch (ex, stack) {
        emit(AuthenticationError(exception: ex, stackTrace: stack));
      } on Exception catch (ex, stack) {
        emit(AuthenticationError(exception: ex, stackTrace: stack));
      }
    }
  }

  Future<void> logOut() async {
    emit(Unauthenticated());
  }
}
