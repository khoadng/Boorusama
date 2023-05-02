// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/domain/boorus.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit({
    required this.currentBooruConfigRepository,
    required this.booruConfig,
  }) : super(Unauthenticated());

  final CurrentBooruConfigRepository currentBooruConfigRepository;
  final BooruConfig booruConfig;

  Future<void> logIn() async {
    if (booruConfig.hasLoginDetails()) {
      emit(Authenticated(booruConfig: booruConfig));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> logOut() async {
    emit(Unauthenticated());
  }
}
