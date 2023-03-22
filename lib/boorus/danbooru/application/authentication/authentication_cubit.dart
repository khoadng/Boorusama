// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/domain/boorus.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit({
    required this.currentUserBooruRepository,
    required this.booru,
  }) : super(Unauthenticated());

  final CurrentUserBooruRepository currentUserBooruRepository;
  final Booru booru;

  Future<void> logIn() async {
    final userBooru = await currentUserBooruRepository.get();
    if (userBooru.hasLoginDetails() &&
        userBooru!.booruId == booru.booruType.index) {
      emit(Authenticated(userBooru: userBooru));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> logOut() async {
    emit(Unauthenticated());
  }
}
