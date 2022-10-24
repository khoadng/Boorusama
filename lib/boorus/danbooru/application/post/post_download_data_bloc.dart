import 'dart:io';

import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/services/bulk_downloader.dart';
import 'package:boorusama/core/infra/infra.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

class PostDownloadDataState extends Equatable {
  const PostDownloadDataState({
    required this.totalCount,
    required this.doneCount,
    required this.downloadItemIds,
    required this.isDone,
    required this.storagePath,
  });

  factory PostDownloadDataState.initial() => const PostDownloadDataState(
        totalCount: 0,
        doneCount: 0,
        downloadItemIds: {},
        isDone: false,
        storagePath: '',
      );

  final int totalCount;
  final int doneCount;
  final Set<int> downloadItemIds;
  final bool isDone;
  final String storagePath;

  PostDownloadDataState copyWith({
    int? totalCount,
    int? doneCount,
    Set<int>? downloadItemIds,
    bool? isDone,
    String? storagePath,
  }) =>
      PostDownloadDataState(
        totalCount: totalCount ?? this.totalCount,
        doneCount: doneCount ?? this.doneCount,
        downloadItemIds: downloadItemIds ?? this.downloadItemIds,
        isDone: isDone ?? this.isDone,
        storagePath: storagePath ?? this.storagePath,
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
  final int? postCount;

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
    required this.data,
  });

  final DownloadData data;

  @override
  List<Object?> get props => [data];
}

class PostDownloadDataBloc
    extends Bloc<PostDownloadDataEvent, PostDownloadDataState> {
  PostDownloadDataBloc({
    required PostRepository postRepository,
    required BulkDownloader downloader,
  }) : super(PostDownloadDataState.initial()) {
    on<PostDownloadDataFetched>((event, emit) async {
      final permission = await Permission.storage.status;
      //TODO: ask permission here, set some state to notify user
      if (permission != PermissionStatus.granted) {
        final status = await Permission.storage.request();
        if (status != PermissionStatus.granted) {
          return;
        }
      }

      final storagePath = await _createSubfolderIfNeeded(
        fixInvalidCharacterForPathName(event.tag),
      );
      emit(state.copyWith(
        totalCount: event.postCount,
        storagePath: storagePath,
      ));
      if (event.postCount != null) {
        final pages = (event.postCount! / 60).ceil();
        for (var i = 1; i <= pages; i += 1) {
          final posts = await postRepository.getPosts(event.tag, i);

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
      } else {
        var page = 1;
        final intPosts = await postRepository.getPosts(event.tag, page);
        final postStack = [intPosts];

        while (postStack.isNotEmpty) {
          final posts = postStack.removeLast();
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
          page += 1;
          final next = await postRepository.getPosts(event.tag, page);
          if (next.isNotEmpty) {
            postStack.add(next);
          }
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
          totalCount: newset.length,
        ));
      },
    );

    on<_DownloadDone>((event, emit) async {
      if (state.downloadItemIds.contains(event.data.postId)) {
        final newset = {...state.downloadItemIds};
        // ignore: cascade_invocations
        newset.remove(event.data.postId);
        final from = event.data.path;
        final to = '${state.storagePath}/${event.data.fileName}';
        if (kDebugMode) {
          print('Moving $from to $to');
        }
        await moveFile(File(from), to);
        emit(state.copyWith(
          doneCount: state.totalCount - newset.length,
          downloadItemIds: newset,
        ));
      }
    });

    downloader.stream
        .listen(
          (data) => add(_DownloadDone(data: data)),
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

Future<String> _createSubfolderIfNeeded(
  String folderName,
) async {
  final downloadDir = await IOHelper.getDownloadPath();
  final folder = '$downloadDir/$folderName';

  if (!Directory(folder).existsSync()) {
    Directory(folder).createSync();
  }

  return folder;
}

Future<File> moveFile(File sourceFile, String newPath) async {
  try {
    // prefer using rename as it is probably faster
    return await sourceFile.rename(newPath);
  } on FileSystemException catch (_) {
    // if rename fails, copy the source file and then delete it
    final newFile = await sourceFile.copy(newPath);
    await sourceFile.delete();

    return newFile;
  }
}

String fixInvalidCharacterForPathName(String str) =>
    str.replaceAll(RegExp(r'[\\/*?:"<>|]'), '_');
