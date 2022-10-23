import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/services/bulk_downloader.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class PostDownloadDataState extends Equatable {
  const PostDownloadDataState({
    required this.totalCount,
    required this.doneCount,
    required this.downloadItemIds,
    required this.isDone,
  });

  factory PostDownloadDataState.initial() => const PostDownloadDataState(
        totalCount: 0,
        doneCount: 0,
        downloadItemIds: {},
        isDone: false,
      );

  final int totalCount;
  final int doneCount;
  final Set<int> downloadItemIds;
  final bool isDone;

  PostDownloadDataState copyWith({
    int? totalCount,
    int? doneCount,
    Set<int>? downloadItemIds,
    bool? isDone,
  }) =>
      PostDownloadDataState(
        totalCount: totalCount ?? this.totalCount,
        doneCount: doneCount ?? this.doneCount,
        downloadItemIds: downloadItemIds ?? this.downloadItemIds,
        isDone: isDone ?? this.isDone,
      );

  @override
  List<Object?> get props => [totalCount, doneCount, downloadItemIds, isDone];
}

abstract class PostDownloadDataEvent extends Equatable {
  const PostDownloadDataEvent();
}

class PostDownloadDataFetched extends PostDownloadDataEvent {
  const PostDownloadDataFetched({
    required this.tag,
    required this.postCount,
  });

  final String tag;
  final int postCount;

  @override
  List<Object?> get props => [tag, postCount];
}

class _DownloadRequested extends PostDownloadDataEvent {
  const _DownloadRequested({
    required this.post,
    required this.tagName,
  });

  final Post post;
  final String tagName;

  @override
  List<Object?> get props => [post, tagName];
}

class _DownloadDone extends PostDownloadDataEvent {
  const _DownloadDone({
    required this.postId,
  });

  final int postId;

  @override
  List<Object?> get props => [postId];
}

class PostDownloadDataBloc
    extends Bloc<PostDownloadDataEvent, PostDownloadDataState> {
  PostDownloadDataBloc({
    required PostRepository postRepository,
    required BulkDownloader downloader,
  }) : super(PostDownloadDataState.initial()) {
    on<PostDownloadDataFetched>((event, emit) async {
      emit(state.copyWith(totalCount: event.postCount));
      final pages = (event.postCount / 60).ceil();
      for (var i = 1; i <= pages; i += 1) {
        final posts = await postRepository.getPosts(event.tag, i);
        // final metadatas = posts
        //     .map((e) =>
        //         PostDownloadMetadata(downloadUrl: e.downloadUrl, postId: e.id))
        //     .toList();
        for (final p in posts) {
          if (state.downloadItemIds.contains(p.id)) continue;

          add(_DownloadRequested(post: p, tagName: event.tag));

          emit(state.copyWith(
            downloadItemIds: {
              ...state.downloadItemIds,
              p.id,
            },
          ));
        }
      }
    });

    on<_DownloadRequested>(
      (event, emit) async {
        await downloader.enqueueDownload(event.post, folderName: event.tagName);
        final newset = {
          ...state.downloadItemIds,
          event.post.id,
        };
        emit(state.copyWith(
          downloadItemIds: newset,
        ));
      },
    );

    on<_DownloadDone>((event, emit) {
      if (state.downloadItemIds.contains(event.postId)) {
        final newset = {...state.downloadItemIds};
        // ignore: cascade_invocations
        newset.remove(event.postId);

        emit(state.copyWith(
          doneCount: state.totalCount - newset.length,
          downloadItemIds: newset,
        ));
      }
    });

    downloader.stream
        .listen(
          (postId) => add(_DownloadDone(postId: postId)),
        )
        .addTo(compositeSubscription);
  }

  final CompositeSubscription compositeSubscription = CompositeSubscription();

  @override
  Future<void> close() {
    compositeSubscription.dispose();

    return super.close();
  }
}

class PostDownloadMetadata extends Equatable {
  const PostDownloadMetadata({
    required this.downloadUrl,
    required this.postId,
  });

  final int postId;
  final String downloadUrl;

  @override
  List<Object?> get props => [postId, downloadUrl];
}
