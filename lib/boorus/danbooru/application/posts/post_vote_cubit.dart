// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';

@immutable
abstract class PostVoteState {}

class PostVoteInitial extends PostVoteState {}

class PostVoteLoading extends PostVoteState {}

class PostVoteLoaded extends PostVoteState {
  final List<PostVote> postVotes;
  PostVoteLoaded(this.postVotes);
}

class PostVoteError extends PostVoteState {
  final String message;
  PostVoteError(this.message);
}

class PostVoteCubit extends Cubit<PostVoteState> {
  final PostVoteRepository _repository;
  final Map<int, PostVote> _cache = {};

  PostVoteCubit(this._repository) : super(PostVoteInitial());

  Future<void> upvote(int postId) async {
    try {
      emit(PostVoteLoading());
      PostVote? postVote = await _repository.upvote(postId);
      _addToCache(postVote);
      emit(PostVoteLoaded(_cache.values.toList()));
    } catch (e) {
      emit(PostVoteError(e.toString()));
    }
  }

  Future<void> downvote(int postId) async {
    try {
      emit(PostVoteLoading());
      PostVote? postVote = await _repository.downvote(postId);
      _addToCache(postVote);
      emit(PostVoteLoaded(_cache.values.toList()));
    } catch (e) {
      emit(PostVoteError(e.toString()));
    }
  }

  Future<void> getVotes(List<int> postIds) async {
    try {
      emit(PostVoteLoading());

      List<int> postIdsToFetch =
          postIds.where((postId) => !_cache.containsKey(postId)).toList();

      if (postIdsToFetch.isNotEmpty) {
        List<PostVote> fetchedPostVotes =
            await _repository.getPostVotes(postIdsToFetch);
        for (var postVote in fetchedPostVotes) {
          _addToCache(postVote);
        }
      }

      List<PostVote> postVotes = postIds
          .map((postId) => _cache[postId])
          .where((postVote) => postVote != null)
          .cast<PostVote>()
          .toList();

      emit(PostVoteLoaded(postVotes));
    } catch (e) {
      emit(PostVoteError(e.toString()));
    }
  }

  void _addToCache(PostVote? postVote) {
    if (postVote != null) {
      _cache[postVote.postId] = postVote;
    }
  }
}
