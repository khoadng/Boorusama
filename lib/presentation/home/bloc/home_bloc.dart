import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState.initial());

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    yield* event.map(
      topTabChanged: (e) => _mapTopTabChangedToState(e),
      bottomTabChanged: (e) => _mapBottomTabChangedToState(e),
      searched: (e) => _mapSearchedToState(e),
      reset: (e) => _mapResetToState(e),
    );
  }

  Stream<HomeState> _mapTopTabChangedToState(_TopTabChanged event) async* {
    yield state.copyWith(
      topTabIndex: event.tabIndex,
    );
  }

  Stream<HomeState> _mapBottomTabChangedToState(
      _BottomTabChanged event) async* {
    yield state.copyWith(
      bottomTabIndex: event.tabIndex,
    );
  }

  Stream<HomeState> _mapSearchedToState(_Searched event) async* {
    yield state.copyWith(
      topTabIndex: 0,
      query: event.query,
    );
  }

  Stream<HomeState> _mapResetToState(_Reset event) async* {
    yield state.copyWith(
      topTabIndex: 0,
      query: "",
    );
  }
}
