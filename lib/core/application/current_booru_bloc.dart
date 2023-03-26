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
    required this.booruConfig,
  });

  factory CurrentBooruState.initial() =>
      const CurrentBooruState(booru: null, booruConfig: null);

  final Booru? booru;
  final BooruConfig? booruConfig;

  CurrentBooruState copyWith({
    Booru? Function()? booru,
    BooruConfig? Function()? booruConfig,
  }) =>
      CurrentBooruState(
        booru: booru != null ? booru() : this.booru,
        booruConfig: booruConfig != null ? booruConfig() : this.booruConfig,
      );

  @override
  List<Object?> get props => [booru, booruConfig];
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
    required this.booruConfig,
    required this.settings,
  });

  final BooruConfig booruConfig;
  final Settings settings;

  @override
  List<Object?> get props => [booruConfig, settings];
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
        final booruConfig = users.firstWhereOrNull(
            (x) => x.id == event.settings.currentBooruConfigId);

        final booru = booruConfig != null
            ? booruFactory.from(type: intToBooruType(booruConfig.booruId))
            : null;

        emit(state.copyWith(
          booru: () => booru,
          booruConfig: () => booruConfig,
        ));
      }
    });

    on<CurrentBooruChanged>((event, emit) async {
      await settingsCubit.update(event.settings.copyWith(
        currentBooruConfigId: event.booruConfig.id,
      ));

      final booru =
          booruFactory.from(type: intToBooruType(event.booruConfig.booruId));

      emit(state.copyWith(
        booru: () => booru,
        booruConfig: () => event.booruConfig,
      ));
    });
  }
}
