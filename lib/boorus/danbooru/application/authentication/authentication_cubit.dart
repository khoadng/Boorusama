// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/profiles.dart';
import 'package:boorusama/core/domain/boorus.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit({
    required this.currentUserBooruRepository,
    required this.profileRepository,
  }) : super(Unauthenticated());

  final CurrentUserBooruRepository currentUserBooruRepository;
  final ProfileRepository profileRepository;

  Future<void> logIn([String username = '', String password = '']) async {
    final userBooru = await currentUserBooruRepository.get();
    if (userBooru.hasLoginDetails()) {
      emit(Authenticated(userBooru: userBooru!));
    } else {
      emit(Unauthenticated());
    }
    // ignore: no-empty-block
  }

  Future<void> logOut() async {
    emit(Unauthenticated());
  }
}
