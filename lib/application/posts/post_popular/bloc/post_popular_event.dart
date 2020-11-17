part of 'post_popular_bloc.dart';

@freezed
abstract class PostPopularEvent with _$PostPopularEvent {
  const factory PostPopularEvent.requested({
    @required DateTime date,
    @required TimeScale scale,
    @required int page,
  }) = _Requested;
  const factory PostPopularEvent.moreRequested({
    @required DateTime date,
    @required TimeScale scale,
    @required int page,
  }) = _MoreRequested;
}
