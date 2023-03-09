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
  }) : super(Unauthenticated());

  final AccountRepository accountRepository;
  final ProfileRepository profileRepository;

  Future<void> logIn([String username = '', String password = '']) async {
    final account = await accountRepository.get();
    if (account != Account.empty) {
      emit(Authenticated(account: account));
    } else {
      emit(Unauthenticated());
    }
    // ignore: no-empty-block
  }

  Future<void> logOut() async {
    emit(Unauthenticated());
  }
}
