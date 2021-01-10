part of 'home_bloc.dart';

@freezed
abstract class HomeEvent with _$HomeEvent {
  const factory HomeEvent.topTabChanged({
    @required int tabIndex,
  }) = _TopTabChanged;

  const factory HomeEvent.bottomTabChanged({
    @required int tabIndex,
  }) = _BottomTabChanged;

  const factory HomeEvent.searched({
    @required String query,
  }) = _Searched;

  const factory HomeEvent.reset() = _Reset;
}
