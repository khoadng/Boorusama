part of 'comment_bloc.dart';

@freezed
abstract class CommentEvent with _$CommentEvent {
  const factory CommentEvent.requested({@required int postId}) = _Requested;
  const factory CommentEvent.added({
    @required int postId,
    @required String content,
  }) = _Added;
}
