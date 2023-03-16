import 'package:boorusama/boorus/booru.dart';
import 'package:boorusama/boorus/booru_factory.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/user_booru.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/user_booru_repository.dart';
import 'package:boorusama/core/application/settings/settings_cubit.dart';
import 'package:boorusama/core/domain/settings/settings.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentBooruState extends Equatable {
  const CurrentBooruState({
    required this.booru,
    required this.userBooru,
  });

  factory CurrentBooruState.initial() =>
      const CurrentBooruState(booru: null, userBooru: null);

  final Booru? booru;
  final UserBooru? userBooru;

  CurrentBooruState copyWith({
    Booru? Function()? booru,
    UserBooru? Function()? userBooru,
  }) =>
      CurrentBooruState(
        booru: booru != null ? booru() : this.booru,
        userBooru: userBooru != null ? userBooru() : this.userBooru,
      );

  @override
  List<Object?> get props => [booru, userBooru];
}

abstract class CurrentBooruEvent extends Equatable {
  const CurrentBooruEvent();
}

class CurrentBooruFetched extends CurrentBooruEvent {
  const CurrentBooruFetched(this.settings);
  final Settings settings;

  @override
  List<Object?> get props => [settings];
}

class CurrentBooruChanged extends CurrentBooruEvent {
  const CurrentBooruChanged({
    required this.booru,
    required this.settings,
  });

  final BooruType booru;
  final Settings settings;

  @override
  List<Object?> get props => [booru, settings];
}

class CurrentBooruBloc extends Bloc<CurrentBooruEvent, CurrentBooruState> {
  CurrentBooruBloc({
    required SettingsCubit settingsCubit,
    required BooruFactory booruFactory,
    required UserBooruRepository userBooruRepository,
  }) : super(CurrentBooruState.initial()) {
    on<CurrentBooruFetched>((event, emit) async {
      if (event.settings.currentBooru != BooruType.unknown) {
        final booru = booruFactory.from(type: event.settings.currentBooru);
        final users = await userBooruRepository.getAll();
        final userBooru =
            users.firstWhereOrNull((x) => x.booruId == booru.booruType.index);

        emit(state.copyWith(
          booru: () => booru,
          userBooru: () => userBooru,
        ));
      }
    });

    on<CurrentBooruChanged>((event, emit) async {
      final booru = booruFactory.from(type: event.booru);
      final users = await userBooruRepository.getAll();

      final userBooru =
          users.firstWhereOrNull((x) => x.booruId == booru.booruType.index);

      await settingsCubit.update(event.settings.copyWith(
        currentBooru: booru.booruType,
      ));

      emit(state.copyWith(
        booru: () => booru,
        userBooru: () => userBooru,
      ));
    });
  }
}
