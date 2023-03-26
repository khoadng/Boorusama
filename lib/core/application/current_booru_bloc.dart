// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/settings/settings_cubit.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/settings.dart';

class CurrentBooruState extends Equatable {
  const CurrentBooruState({
    required this.booru,
    required this.userBooru,
  });

  factory CurrentBooruState.initial() =>
      const CurrentBooruState(booru: null, userBooru: null);

  final Booru? booru;
  final BooruConfig? userBooru;

  CurrentBooruState copyWith({
    Booru? Function()? booru,
    BooruConfig? Function()? userBooru,
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
    required this.userBooru,
    required this.settings,
  });

  final BooruConfig userBooru;
  final Settings settings;

  @override
  List<Object?> get props => [userBooru, settings];
}

class CurrentBooruBloc extends Bloc<CurrentBooruEvent, CurrentBooruState> {
  CurrentBooruBloc({
    required SettingsCubit settingsCubit,
    required BooruFactory booruFactory,
    required BooruConfigRepository userBooruRepository,
  }) : super(CurrentBooruState.initial()) {
    on<CurrentBooruFetched>((event, emit) async {
      if (event.settings.hasSelectedBooru) {
        final users = await userBooruRepository.getAll();
        final userBooru = users
            .firstWhereOrNull((x) => x.id == event.settings.currentUserBooruId);

        final booru = userBooru != null
            ? booruFactory.from(type: intToBooruType(userBooru.booruId))
            : null;

        emit(state.copyWith(
          booru: () => booru,
          userBooru: () => userBooru,
        ));
      }
    });

    on<CurrentBooruChanged>((event, emit) async {
      await settingsCubit.update(event.settings.copyWith(
        currentUserBooruId: event.userBooru.id,
      ));

      final booru =
          booruFactory.from(type: intToBooruType(event.userBooru.booruId));

      emit(state.copyWith(
        booru: () => booru,
        userBooru: () => event.userBooru,
      ));
    });
  }
}
