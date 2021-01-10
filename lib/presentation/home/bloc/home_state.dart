part of 'home_bloc.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @required int topTabIndex,
    @required int bottomTabIndex,
    @required String query,
  }) = _HomeState;

  factory HomeState.initial() => HomeState(
        topTabIndex: 0,
        bottomTabIndex: 0,
        query: "",
      );
}
