part of 'post_most_viewed_bloc.dart';

@freezed
abstract class PostMostViewedEvent with _$PostMostViewedEvent {
  const factory PostMostViewedEvent.requested({
    @required DateTime date,
  }) = _Requested;
  const factory PostMostViewedEvent.moreRequested({
    @required DateTime date,
  }) = _MoreRequested;
}
