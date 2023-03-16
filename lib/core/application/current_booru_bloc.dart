import 'package:boorusama/boorus/booru.dart';
import 'package:boorusama/boorus/booru_factory.dart';
import 'package:boorusama/core/application/api/api.dart';
import 'package:boorusama/core/application/settings/settings_cubit.dart';
import 'package:boorusama/core/domain/settings/settings.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentBooruState extends Equatable {
  const CurrentBooruState({
    required this.booru,
  });

  factory CurrentBooruState.initial() => const CurrentBooruState(booru: null);

  final Booru? booru;

  CurrentBooruState copyWith({
    Booru? Function()? booru,
  }) =>
      CurrentBooruState(
        booru: booru != null ? booru() : this.booru,
      );

  @override
  List<Object?> get props => [booru];
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
    required ApiCubit apiCubit,
  }) : super(CurrentBooruState.initial()) {
    on<CurrentBooruFetched>((event, emit) async {
      final booru = booruFactory.from(type: event.settings.currentBooru);

      emit(state.copyWith(
        booru: () => booru,
      ));
    });

    on<CurrentBooruChanged>((event, emit) {
      final booru = booruFactory.from(type: event.booru);

      settingsCubit.update(event.settings.copyWith(
        currentBooru: booru.booruType,
      ));

      apiCubit.changeApi(booru);

      emit(state.copyWith(
        booru: () => booru,
      ));
    });
  }
}
