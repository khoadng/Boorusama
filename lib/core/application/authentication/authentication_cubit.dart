// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/domain/boorus.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit({
    required this.currentBooruConfigRepository,
    required this.booru,
  }) : super(Unauthenticated());

  final CurrentBooruConfigRepository currentBooruConfigRepository;
  final Booru booru;

  Future<void> logIn() async {
    final booruConfig = await currentBooruConfigRepository.get();
    if (booruConfig.hasLoginDetails() &&
        booruConfig!.booruId == booru.booruType.index) {
      emit(Authenticated(booruConfig: booruConfig));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> logOut() async {
    emit(Unauthenticated());
  }
}
